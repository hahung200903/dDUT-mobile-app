import jwt from 'jsonwebtoken';

export const authMiddleware = (req, res, next) => {
    if (process.env.FAKE_AUTH === "true") {
        req.user = { id: "102210238" }; 
        return next();
    }

    if (!req.headers.authorization) {
        return res.status(401).json({ message: 'Authorization header is required' });
    }

    const authHeaderParts = req.headers.authorization.split(' ');
    if (authHeaderParts.length !== 2 || authHeaderParts[0] !== 'Bearer') {
        return res.status(401).json({ message: 'Format: Bearer <token>' });
    }

    const token = authHeaderParts[1];

    try {
        const decodedPayload = jwt.verify(token, process.env.JWT_TOKEN);
        // Lấy username làm studentId (loại bỏ đuôi email nếu có)
        let username = decodedPayload.unique_name?.replace(/@sv1\.dut\.udn\.vn$/, "") || decodedPayload.id;
        req.user = { id: username };
        next();
    } catch (err) {
        return res.status(401).json({ message: 'Invalid or expired token.' });
    }
};