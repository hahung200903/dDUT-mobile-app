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

router.get('/results', async (req, res) => {
  try {
    const studentId = String(req.query.studentId || '');
    if (!studentId) return res.status(400).json({ error: 'Missing studentId' });

    const p = await getPool();
    const r = await p.request()
      .input('mahs', sql.VarChar, studentId)
      .query(`
        SELECT
          tk.IdCode    AS [Kỳ học],
          tk.MaHS      AS [Mã sinh viên],
          l.TenLopHP   AS [Tên học phần],
          tk.MaLopHP   AS [Mã lớp học phần],
          tk.SoTC      AS [Số tín chỉ],
          c.VarString3 AS [Công thức điểm],
          tk.DiemC     AS [Tổng kết],
          tk.Diem      AS [Thang 10],
          tk.Diem4     AS [Thang 4]
        FROM [DHBK_CDS].[dbo].[tmDiemkyhoc] tk
        LEFT JOIN [DHBK_CDS].[dbo].[tmLopHP] l ON l.MaLopHP = tk.MaLopHP
        LEFT JOIN [DHBK_CDS].[dbo].[congthucdiem] c ON c.Macongthuc = l.CongThucDiem
        WHERE tk.MaHS = @mahs AND tk.MaHP IS NOT NULL
        ORDER BY tk.IDCode DESC, tk.MaHP;
      `);

    res.json({ "Kết quả học tập": r.recordset });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

router.get('/stats', async (req, res) => {
  try {
    const studentId = String(req.query.studentId || '');
    if (!studentId) return res.status(400).json({ error: 'Missing studentId' });

    const p = await getPool();

    const perSemester = await p.request()
      .input('mahs', sql.VarChar, studentId)
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

    const overall = await p.request()
      .input('mahs', sql.VarChar, studentId)
      .query(`
        SELECT 
          CAST(SUM(CAST(ISNULL(SoTC,0) AS float) * CAST(ISNULL(Diem,0) AS float))
                / NULLIF(SUM(CAST(ISNULL(SoTC,0) AS float)),0) AS decimal(5,2)) AS gpa10,
          SUM(ISNULL(SoTC,0)) AS totalCredits
        FROM [DHBK_CDS].[dbo].[tmDiemkyhoc]
        WHERE MaHS = @mahs
      `);

    res.json({
      semesters: perSemester.recordset.map(r => r.semesterCode),
      gpaPerSemester: perSemester.recordset.map(r => Number(r.gpa10)),
      creditsPerSemester: perSemester.recordset.map(r => Number(r.tc)),
      overall: overall.recordset[0] || { gpa10: null, totalCredits: 0 },
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

app.use('/api', router);

const port = Number(process.env.PORT || 8080);
app.listen(port, () => console.log(`REST API listening on :${port}`));
