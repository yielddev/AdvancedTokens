## SafeERC20

SafeERC20 implements wrappers around standard ERC20 functions that revert on failure. This allows an application or external implemented to confidently utilize arbitrary tokens via the ERC20 interface even if they implement non standard behavior or return a boolean instead of throwing. 

SafeERC20 should be used when writing a contract that interacts with arbitrary and/or untrusted ERC20 tokens. 