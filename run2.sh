#!/bin/bash -e

echo '===================='
echo '== Part2: Phase 2 =='
echo '===================='
echo

# check
which circom > /dev/null
if [ "$?" -ne 0 ]; then
    echo "Please install circom: https://docs.circom.io/getting-started/installation/#installing-circom"
    exit 1
fi

# clean
rm -rf circuit_js
rm -f circuit_*.zkey circuit.r1cs circuit.sym verification_key.json

# compile circuit
circom circuit.circom --r1cs --wasm --sym

# view information
npx snarkjs r1cs info circuit.r1cs


# phase 2

# setup
npx snarkjs groth16 setup circuit.r1cs pot14_final.ptau circuit_0000.zkey

# contribute to the Phase 2 ceremony
npx snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="1st Contributor Name" -v -e="random text 1"

# apply random beacon
npx snarkjs zkey beacon circuit_0001.zkey circuit_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"

# verify the final zkey
npx snarkjs zkey verify circuit.r1cs pot14_final.ptau circuit_0001.zkey

# export the verification key
npx snarkjs zkey export verificationkey circuit_final.zkey verification_key.json

echo
echo '================='
echo '== Part2: done =='
echo '================='
