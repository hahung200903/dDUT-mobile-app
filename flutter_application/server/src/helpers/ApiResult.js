export default class ApiResult {
    constructor(isSuccess, data, message) {
        this.isSuccess = isSuccess;
        this.data = data;
        this.message = message;
    }

    static Success(data, message = "Operation was successful.") {
        return new ApiResult(true, data, message);
    }

    static Fail(message) {
        return new ApiResult(false, null, message);
    }
}