/**
    A mock DelegatorManager to make SwapPair_Flow_stFlow compilable
*/

pub contract DelegatorManager {
    access(self) let epochSnapshotHistory: {UInt64: EpochSnapshot}
    pub var quoteEpochCounter: UInt64 

    pub struct EpochSnapshot {
        // Snapshotted protocol epoch                                           
        pub let epochCounter: UInt64
        /// Price: stFlow to Flow (>= 1.0)                                      
        pub var scaledQuoteStFlowFlow: UInt256                                   
        /// Price: Flow to stFlow (<= 1.0)                                      
        pub var scaledQuoteFlowStFlow: UInt256 

        init(epochCounter: UInt64) {
            self.epochCounter = epochCounter
            self.scaledQuoteStFlowFlow = 1
            self.scaledQuoteFlowStFlow = 1
        }
    }

    pub fun borrowEpochSnapshot(at: UInt64): &EpochSnapshot {                   
        return (&self.epochSnapshotHistory[at] as &EpochSnapshot?) ?? panic("EpochSnapshot index out of range")                                                                                           
    }

    pub fun borrowCurrentQuoteEpochSnapshot(): &EpochSnapshot {                                                                                                                                           
        return self.borrowEpochSnapshot(at: self.quoteEpochCounter)                 
    }

    init() {
        self.quoteEpochCounter = 0
        self.epochSnapshotHistory = {}
        self.epochSnapshotHistory[0] = EpochSnapshot(epochCounter: 0)
    }
}