pub contract SwapError {
    pub enum ErrorCode: UInt8 {
        pub case NO_ERROR
        pub case CERTIFICATE_FAILED
        pub case INVALID_ADDRESS
        pub case INVALID_CALC
        // Pair related:
        pub case INVALID_PARAMETERS
        pub case INSUFFICENT_INPUT_AMOUNT
        pub case INSUFFICENT_OUTPUT_AMOUNT
        pub case INSUFFICENT_LIQUIDITY

        // PairFactor related:
        pub case CANNOT_CREATE_PAIR_WITH_SAME_TOKENS
        pub case ADD_PAIR_DUPLICATED
        pub case CANNOT_ACCESS_PAIR_PUBLIC_CAPABILITY
        // Router related:
        pub case ADD_ROUTER_NO_ORACLE_PRICE
    }

    pub fun ErrorEncode(msg: String, err: ErrorCode): String {
        return "[IncSwapErrorMsg:".concat(msg).concat("]").concat(
               "[IncSwapErrorCode:").concat(err.rawValue.toString()).concat("]")
    }
    
    init() {
    }
}