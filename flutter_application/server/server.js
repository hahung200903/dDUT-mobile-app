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
    if (!studentId) return res.status(400).json({ error: 'Missing studentId' });
    if (!/^[A-Za-z0-9._-]{3,50}$/.test(studentId)) {
      return res.status(400).json({ error: 'Invalid studentId format' });
    }

    const p = await getPool();
    const rq = p.request();
    rq.multiple = true;
    rq.input('mahs', sql.VarChar, studentId);

    const result = await rq.query(`
      -- 1) Dữ liệu theo từng kỳ
      SELECT
        IdCode                                      AS semesterCode,
        CAST(ISNULL(DiemTBTL, 0) AS decimal(4,2))  AS gpa4,
        CAST(ISNULL(DiemRL,   0) AS int)           AS drl,
        CAST(ISNULL(HPDangky, 0) AS int)           AS creditsInSemester
      FROM [DHBK_CDS].[dbo].[TmHocvu]
      WHERE MaHS = @mahs
      ORDER BY TRY_CONVERT(int, NULLIF(IdCode,'0'));

      -- 2) Tổng quan
      ;WITH hv AS (
        SELECT
          IdCode,
          CAST(ISNULL(DiemTBTL,  0) AS decimal(4,2)) AS gpa4_latest_candidate,
          CAST(ISNULL(HPTichLuy, 0) AS int)          AS total_acc_credits,   -- tên cột này
          Namhoc,
          CAST(ISNULL(DiemRL,    0) AS float)        AS drl_for_avg
        FROM [DHBK_CDS].[dbo].[TmHocvu]
        WHERE MaHS = @mahs
      ),
      latest AS (
        SELECT TOP (1)
          gpa4_latest_candidate AS gpa4_latest,
          total_acc_credits      AS total_acc_credits,  -- dùng đúng tên ở trên
          Namhoc                 AS stage
        FROM hv
        ORDER BY TRY_CONVERT(int, NULLIF(IdCode,'0')) DESC
      ),
      agg AS (
        SELECT AVG(drl_for_avg) AS avg_drl FROM hv
      )
      SELECT
        CAST(l.gpa4_latest       AS decimal(4,2)) AS gpa4,
        CAST(l.total_acc_credits AS int)          AS totalAccumCredits,
        CAST(a.avg_drl           AS decimal(5,2)) AS avgConduct,
        l.stage                                     AS stage
      FROM latest l CROSS JOIN agg a;
    `);

    const per = result.recordsets?.[0] ?? [];
    const ov  = result.recordsets?.[1]?.[0] ?? null;
    const toNum = v => (v === null || v === undefined || v === '' ? null : Number(v));

    return res.json({
      "Kỳ học": per.map(r => String(r.semesterCode ?? '')),
      "GPA từng kỳ": per.map(r => toNum(r.gpa4)),
      "Điểm rèn luyện từng kỳ": per.map(r => toNum(r.drl)),
      "Số tín chỉ đăng ký từng kì": per.map(r => toNum(r.creditsInSemester)),
      "Tổng quan": {
        "GPA thang 4": ov ? toNum(ov.gpa4) : null,
        "Số tín chỉ tích luỹ": ov ? toNum(ov.totalAccumCredits) : 0,
        "Điểm rèn luyện trung bình": ov ? toNum(ov.avgConduct) : null,
        "Năm học": ov ? String(ov.stage ?? '') : ''
      }
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});



app.use('/api', router);
router.get('/health', (req, res) => res.json({ ok: true }));

const port = Number(process.env.PORT || 8080);
app.listen(port, () => console.log(`REST API listening on :${port}`));
