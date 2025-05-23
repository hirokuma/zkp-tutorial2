#!/bin/bash -e

# clean
rm -f verifier.sol

# solidity file
npx snarkjs zkey export solidityverifier circuit_final.zkey verifier.sol

# simulate
npx snarkjs zkey export soliditycalldata public.json proof.json
