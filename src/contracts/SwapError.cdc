pub contract SwapError {
    pub enum ErrorCode: UInt8 {
        pub case NO_ERROR
        
        pub case INVALID_PARAMETERS
        pub case CANNOT_CREATE_PAIR_WITH_SAME_TOKENS
        pub case ADD_PAIR_DUPLICATED
        pub case SLIPPAGE_OFFSET_TOO_LARGE
        pub case EXCESSIVE_INPUT_AMOUNT
        pub case EXPIRED
<<<<<<< HEAD:src/contracts/SwapError.cdc
        pub case INSUFFICIENT_BALANCE
=======
>>>>>>> 6bba9a0 (add SwapExactTokensForTokens):cadence/contracts/SwapError.cdc
    }

    pub fun ErrorEncode(msg: String, err: ErrorCode): String {
        return "[IncSwapErrorMsg:".concat(msg).concat("]").concat(
               "[IncSwapErrorCode:").concat(err.rawValue.toString()).concat("]")
    }
    
    init() {
    }
}