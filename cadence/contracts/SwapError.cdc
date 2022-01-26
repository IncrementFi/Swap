pub contract SwapError {
    pub enum ErrorCode: UInt8 {
        pub case NO_ERROR
        
        // Common
        pub case INVALID_PARAMETERS

        // PairFactor related:
        pub case CANNOT_CREATE_PAIR_WITH_SAME_TOKENS
        pub case ADD_PAIR_DUPLICATED

        // Router
        pub case SLIPPAGE_OFFSET_TOO_LARGE
    }

    pub fun ErrorEncode(msg: String, err: ErrorCode): String {
        return "[IncSwapErrorMsg:".concat(msg).concat("]").concat(
               "[IncSwapErrorCode:").concat(err.rawValue.toString()).concat("]")
    }
    
    init() {
    }
}