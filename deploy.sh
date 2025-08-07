#!/usr/bin/env bash

# Broadcasting
forge create \
  src/ExchangeDemo.sol:ExchangeDemo \
  --verify \
  --verifier blockscout \
  --verifier-url 'https://testnet.blockscout-api.injective.network/api/' \
  --rpc-url injectiveEvm \
  --private-key $PRIVKEY \
  --value 1ether \
  --broadcast

SmartContractAddress=0x76bd37d4d9acFfD4BE1E2B47c058f701F4B0Eed5

# INJ/USDT
MarketID="0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"

SubaccountID="${SmartContractAddress}000000000000000000000001"

InjectiveAddress="$(injectived query exchange inj-address-from-eth-address $SmartContractAddress)"

echo "(\"$MarketID\",\"$SubaccountID\",\"$InjectiveAddress\",100000000,1000000000000000000,\"my-order-001\",\"sell\",0)"

# deposit to subaccount
cast send \
  --rpc-url injectiveEvm \
  --private-key $PRIVKEY \
  ${SmartContractAddress} \
  "function deposit(string calldata subaccountID, string calldata denom, uint256 amount) external returns (bool)" \
  $SubaccountID "inj" "1000000000000000000"

# dry run withdraw from subaccount
cast call \
  --rpc-url injectiveEvm \
  ${SmartContractAddress} \
  "function withdraw(string calldata subaccountID, string calldata denom, uint256 amount) external returns (bool)" \
  $SubaccountID "inj" "1000000000000000000"

forge inspect src/ExchangeDemo.sol:ExchangeDemo methods

# TODO: dry run create spot limit order
cast call \
  --rpc-url injectiveEvm \
  ${SmartContractAddress} \
  "function createSpotLimitOrder((string,string,string,uint256,uint256,string,string,uint256))" \
  "(\"$MarketID\",\"$SubaccountID\",\"$InjectiveAddress\",100000000,1000000000000000000,\"my-order-001\",\"sell\",0)"
