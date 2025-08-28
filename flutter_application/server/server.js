import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import sql from 'mssql';

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

const sqlConfig = {
  user: process.env.MSSQL_USER,
  password: process.env.MSSQL_PASSWORD,
  server: process.env.MSSQL_HOST,
  database: process.env.MSSQL_DB,
  options: { encrypt: true, trustServerCertificate: true },
  pool: { max: 5, min: 0, idleTimeoutMillis: 30000 },
};

let pool = null;
async function getPool() {
  if (pool?.connected) return pool;
  pool = await new sql.ConnectionPool(sqlConfig).connect();
  return pool;
}

const router = express.Router();

// Lấy kết quả học tập của sinh viên
router.get('/results', async (req, res) => {
  try {
    const studentId = String(req.query.studentId || '').trim();
    if (!studentId) return res.status(400).json({ error: 'Missing studentId' });

    const p = await getPool();
    const r = await p.request()
      .input('mahs', sql.VarChar, studentId)
      .query(`
        SELECT
          tk.IdCode    AS KyHoc,
          tk.MaHS      AS MaSinhVien,
          l.TenLopHP   AS TenHocPhan,
          tk.MaLopHP   AS MaLopHocPhan,
          tk.SoTC      AS SoTinChi,
          c.VarString2 AS DanhSachThanhPhan,
          c.VarString3 AS CongThucDiem,
          tk.DiemC     AS TongKet,
          tk.Diem      AS Thang10,
          tk.Diem4     AS Thang4,

          tk.CUSBT, tk.CUSCC, tk.CUSDA, tk.CUSGK,
          tk.CUSBV, tk.CUSDG, tk.CUSCK, tk.CUSLT,
          tk.CUSTH, tk.CUSTT, tk.CUSKT, tk.CUSHD,
          tk.CUSB1, tk.CUSB2, tk.CUSB3,
          tk.CUSG1, tk.CUSG2,
          tk.CUST1, tk.CUST2, tk.CUST3, tk.CUST4,
          tk.CUSTN, tk.CUSVI, tk.CUSVD,
          tk.CUSDO, tk.CUSQT, tk.CUSBC
        FROM [DHBK_CDS].[dbo].[tmDiemkyhoc] tk
        LEFT JOIN [DHBK_CDS].[dbo].[tmLopHP] l ON l.MaLopHP = tk.MaLopHP
        LEFT JOIN [DHBK_CDS].[dbo].[congthucdiem] c ON c.Macongthuc = l.CongThucDiem
        WHERE tk.MaHS = @mahs AND tk.MaHP IS NOT NULL
        ORDER BY tk.IdCode DESC, tk.MaHP;
      `);

    const num = v => (v === null || v === undefined || v === '' ? null : Number(v));
    const txt = v => (v === null || v === undefined ? '' : String(v));

    const results = r.recordset.map(row => {
      let comps = (row.DanhSachThanhPhan || '')
        .split(/[;,\|]/)
        .map(s => s.trim().toUpperCase())
        .filter(Boolean);

      if (comps.length === 0 && row.CongThucDiem) {
        const m = String(row.CongThucDiem).toUpperCase().match(/\[([A-Z0-9]+)\]/g);
        if (m) comps = [...new Set(m.map(t => t.replace(/[\[\]]/g, '')))];
      }

      const mapCUS = {
        BT: row.CUSBT, CC: row.CUSCC, DA: row.CUSDA, GK: row.CUSGK,
        BV: row.CUSBV, DG: row.CUSDG, CK: row.CUSCK, LT: row.CUSLT,
        TH: row.CUSTH, TT: row.CUSTT, KT: row.CUSKT, HD: row.CUSHD,
        B1: row.CUSB1, B2: row.CUSB2, B3: row.CUSB3,
        G1: row.CUSG1, G2: row.CUSG2,
        T1: row.CUST1, T2: row.CUST2, T3: row.CUST3, T4: row.CUST4,
        TN: row.CUSTN, VI: row.CUSVI, VD: row.CUSVD,
        DO: row.CUSDO, QT: row.CUSQT, BC: row.CUSBC
      };
      const congthucArr = [`Công thức điểm: ${txt(row.CongThucDiem)}`];
      for (const c of comps) congthucArr.push(`${c}: ${mapCUS[c] ?? ''}`);

      return {
        'Kỳ học': txt(row.KyHoc),
        'Mã sinh viên': txt(row.MaSinhVien),
        'Tên học phần': txt(row.TenHocPhan),
        'Mã lớp học phần': txt(row.MaLopHocPhan),
        'Số tín chỉ': num(row.SoTinChi),
        'Chi tiết điểm': congthucArr,
        'Tổng kết': txt(row.TongKet),
        'Thang 10': num(row.Thang10),
        'Thang 4': num(row.Thang4),
      };
    });

    res.json({ 'Kết quả học tập': results });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

// Lấy thông tin học vụ của sinh viên
router.get('/stats', async (req, res) => {
  try {
    const studentId = String(req.query.studentId || '').trim();
    if (!studentId) {
      return res.status(400).json({ error: 'Missing studentId' });
    }

    const p = await getPool();

    // Theo từng kỳ: GPA từ DiemTBTL thang 4, RL từ DiemRL thang 100, tín chỉ đăng ký từ HPDangky
    const per = await p.request()
      .input('mahs', sql.VarChar, studentId)
      .query(`
        SELECT
          IdCode AS semesterCode,
          CAST(ISNULL(DiemTBTL, 0) AS decimal(4,2)) AS gpa4,
          CAST(ISNULL(DiemRL, 0) AS int)            AS drl,
          CAST(ISNULL(HPDangky, 0) AS int)          AS creditsInSemester
        FROM [DHBK_CDS].[dbo].[TmHocvu]
        WHERE MaHS = @mahs
        ORDER BY TRY_CONVERT(int, IdCode)
      `);

    // Tổng quan: GPA & tổng tín chỉ đăng ký (HPDangky) từ TmHocvuTK
    const overall = await p.request()
      .input('mahs', sql.VarChar, studentId)
      .query(`
        SELECT TOP 1
          CAST(ISNULL(DiemTBTL, 0) AS decimal(4,2)) AS gpa4,
          CAST(ISNULL(HPDangky, 0) AS int)          AS totalCredits,
          Namhoc
        FROM [DHBK_CDS].[dbo].[TmHocvuTK]
        WHERE MaHS = @mahs
        ORDER BY Namhoc DESC
      `);

    const rows = per.recordset || [];
    const ov = overall.recordset?.[0] || null;

    res.json({
      semesters: rows.map(r => String(r.semesterCode)),
      gpaPerSemester: rows.map(r => Number(r.gpa4)),         // GPA thang 4
      conductPerSemester: rows.map(r => Number(r.drl)),      // ĐRL thang 100
      creditsPerSemester: rows.map(r => Number(r.creditsInSemester)), // HP đăng ký từng kỳ
      overall: {
        gpa4: ov ? Number(ov.gpa4) : null,
        totalCredits: ov ? Number(ov.totalCredits) : 0,      // tổng HP đăng ký
        stage: ov ? String(ov.Namhoc ?? '') : '',
        warningLevel: '--/--'
      }
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message || 'Internal Server Error' });
  }
});

app.use('/api', router);
router.get('/health', (req, res) => res.json({ ok: true }));

const port = Number(process.env.PORT || 8080);
app.listen(port, () => console.log(`REST API listening on :${port}`));
