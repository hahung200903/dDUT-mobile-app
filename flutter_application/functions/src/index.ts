import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";
import express from "express";
import cors from "cors";
import * as sql from "mssql";

admin.initializeApp();

const app = express();

app.use(cors({ origin: true }));

const cfg = (functions.config() as any).mssql;
if (!cfg) {
  throw new Error(
    'Missing mssql runtime config. Locally, run: firebase functions:config:get > .runtimeconfig.json'
  );
}

const sqlConfig: sql.config = {
  user: cfg.user,
  password: cfg.password,
  server: cfg.host,
  database: cfg.database,
  options: { encrypt: true, trustServerCertificate: true },
  pool: { max: 5, min: 0, idleTimeoutMillis: 30000 },
};

// Helper: đảm bảo chỉ 1 pool được dùng lại
let pool: sql.ConnectionPool | null = null;
async function getPool() {
  if (pool && pool.connected) return pool;
  pool = await new sql.ConnectionPool(sqlConfig).connect();
  return pool;
}

/**
 * GET /results?studentId=<Mahs>
 * Trả về danh sách học phần 1 kỳ hoặc nhiều kỳ (theo mapping Excel “Bảng điểm”)
 * Bảng: [DHBK_CDS].[dbo].[tmDiemkyhoc]
 */
app.get("/results", async (req, res) => {
  try { 
    const studentId = String(req.query.studentId || "");
    if (!studentId) return res.status(400).json({ error: "Missing studentId" });

    const p = await getPool();

    // query: lấy toàn bộ học phần của SV
    const r = await p.request()
      .input("mahs", sql.VarChar, studentId)
      .query(`
        SELECT 
          tk.IdCode    AS semesterCode,   -- Kì học
          tk.MaHS      AS studentId,      -- Mã SV
          tk.MaHP      AS subjectCode,    -- Mã HP
          tk.MaLopHP   AS classCode,      -- Mã lớp HP
          l.TenLopHP   AS subjectTitle,   -- TÊN HỌC PHẦN
          tk.SoTC      AS credits,        -- Số tín chỉ
          tk.Diem      AS score10,        -- Điểm 10
          tk.DiemC     AS scoreChar,      -- Điểm chữ
          tk.Diem4     AS score4          -- Điểm 4 (nếu có)
        FROM [DHBK_CDS].[dbo].[tmDiemkyhoc] tk
        LEFT JOIN [DHBK_CDS].[dbo].[tmLopHP] l
          ON l.MaLopHP = tk.MaLopHP
        WHERE tk.MaHS = @mahs
          AND tk.MaHP IS NOT NULL
        ORDER BY tk.IdCode, tk.MaHP;
  `);
  
    res.json({ results: r.recordset });
  } catch (e:any) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

/**
 * GET /stats?studentId=<Mahs>
 * Trả về thống kê GPA theo học kỳ + TC tích luỹ (mapping từ sheet “Thống kê”)
 * - GPA per semester: tính từ tmDiemkyhoc theo SoTC & Diem
 * - Tổng TC tích luỹ: SUM(SoTC) đến thời điểm hiện tại
 * - GPA tích luỹ: SUM(SoTC*Diem)/SUM(SoTC)
 */
app.get("/stats", async (req, res) => {
  try {
    const studentId = String(req.query.studentId || "");
    if (!studentId) return res.status(400).json({ error: "Missing studentId" });

    const p = await getPool();

    // GPA từng kỳ
    const perSemester = await p.request()
      .input("mahs", sql.VarChar, studentId)
      .query(`
        SELECT 
          IdCode AS semesterCode,
          CAST(SUM(CAST(ISNULL(SoTC,0) AS float) * CAST(ISNULL(Diem,0) AS float)) 
                / NULLIF(SUM(CAST(ISNULL(SoTC,0) AS float)),0) AS decimal(5,2)) AS gpa10,
          SUM(ISNULL(SoTC,0)) AS tc
        FROM [DHBK_CDS].[dbo].[tmDiemkyhoc]
        WHERE MaHS = @mahs
        GROUP BY IdCode
        ORDER BY IdCode
      `);

    // Tổng TC & GPA tích luỹ toàn bộ
    const overall = await p.request()
      .input("mahs", sql.VarChar, studentId)
      .query(`
        SELECT 
          CAST(SUM(CAST(ISNULL(SoTC,0) AS float) * CAST(ISNULL(Diem,0) AS float)) 
                / NULLIF(SUM(CAST(ISNULL(SoTC,0) AS float)),0) AS decimal(5,2)) AS gpa10,
          SUM(ISNULL(SoTC,0)) AS totalCredits
        FROM [DHBK_CDS].[dbo].[tmDiemkyhoc]
        WHERE MaHS = @mahs
      `);

    res.json({
      semesters: perSemester.recordset.map((r:any)=>r.semesterCode),
      gpaPerSemester: perSemester.recordset.map((r:any)=>Number(r.gpa10)),
      creditsPerSemester: perSemester.recordset.map((r:any)=>Number(r.tc)),
      overall: overall.recordset[0] || { gpa10: null, totalCredits: 0 },
    });
  } catch (e:any) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

// Export 1 endpoint duy nhất: /api/**
exports.api = functions.https.onRequest({ region: "asia-southeast1" }, app);
