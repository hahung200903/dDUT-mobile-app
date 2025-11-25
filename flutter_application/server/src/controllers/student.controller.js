import ApiResult from '../helpers/ApiResult.js';
import * as studentService from '../services/student.service.js';

export const getResults = async (req, res) => {
    // Lấy ID từ Token
    const studentId = req.user.id; 

    try {
        const data = await studentService.getStudentResults(studentId);
        res.status(200).json(ApiResult.Success(data, 'Lấy kết quả học tập thành công.'));
    } catch (error) {
        console.error('Error fetching results:', error);
        res.status(500).json(ApiResult.Fail(error.message));
    }
};

export const getStats = async (req, res) => {
    const studentId = req.user.id;

    try {
        const data = await studentService.getStudentStats(studentId);
        res.status(200).json(ApiResult.Success(data, 'Lấy thông tin học vụ thành công.'));
    } catch (error) {
        console.error('Error fetching stats:', error);
        res.status(500).json(ApiResult.Fail(error.message));
    }
};