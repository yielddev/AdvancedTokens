## ERC777 & ERC1363

ERC777 was design to extend the ERC20 token standard with functionality allowing contracts to act as payable upon receipt of a token as well as adding functionality for an administrative operator who may be designated to execute transactions on behalf of a token holder. 

The primary motivation for solving this issue is in response to what is perceived as a major UX issue for ERC20 tokens, namely that they require 2 transactions in order to have a contract be able to execute some logic in response to or along with an ERC20 transaction.

A further motivation to implement these features is the common user error where by ERC20 tokens are sent to a contract address with no established logic for receiving them and become lost forever in the contract. 

For this reason, ERC777 implements send and receive hooks which are, similar to callbacks, logic set to be executed on the sending or receipt of a token. 

Due to the widely held opinion that ERC777 implements insecure patterns and the number of high profile exploits involving ERC777, open zeppelin has deprecated the ERC777 implementation in its library. Effectively, recommending against using the standard in favor of some other solution.

ERC777 has been largely considered vulnerable to reentrancy attacks. As pointed out by lukehutch https://github.com/OpenZeppelin/openzeppelin-contracts/issues/2620#issuecomment-1156118047 the standard is inherently insecure in this way because it calls an external contract (callback) before the state is update. a violation of the check **effect pattern**.

Since the token contract must call an external untrusted callback function, there is high potential for abuse. 

ERC1363 improved on this by implementing a simplified standard to extend ERC20 tokens with functions `transferAndCall` as well as `approveAndCall`. `approveAnCall` in particular can be used to eliminate the second step in the approve, transferFrom flow common to most dapps interacting with ERC20 tokens. 

These additional functions allow `ERC1363Receiver` and `ERC1363Spender` contracts to execute code after either an approval or the the receipt of some tokens. 

This implementation does not override the standard `transfer` and `transferFrom` methods thus maintaining backwards compatibility with ERC20.

It does require contracts that want to receive payments via `approveAndCall` `transferAndCall` or `transferFromAndCall` to implement the appropriate ERC1363 receiver/spender interface. Although, it does not require the spender logic to be registered via ERC-1820. ERC1363 is, overall, a much more minimal and simplified approach to allowing the execution of arbitrary logic on receipt of payment. 