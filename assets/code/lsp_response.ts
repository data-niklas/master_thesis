interface ResponseMessage extends Message {
    result?: any;
    error?: ResponseError;
    id: string | number | null;
}

interface ResponseError {
    code: number;
    message: string;
    data?: any;
}

