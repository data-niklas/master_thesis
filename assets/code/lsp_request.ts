interface RequestMessage extends Message {
    method: string;
    params?: any;
    id: string | number | null;
}

