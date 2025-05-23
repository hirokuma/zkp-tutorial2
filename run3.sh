#!/bin/bash -e

echo '=================='
echo '== Part3: Proof =='
echo '=================='
echo

# clean
rm -f proof.json public.json witness.wtns

# create witness
node circuit_js/generate_witness.js circuit_js/circuit.wasm input.json witness.wtns

# create proof
npx snarkjs groth16 prove circuit_final.zkey witness.wtns proof.json public.json




# verify proof
npx snarkjs groth16 verify verification_key.json public.json proof.json


echo
echo '================='
echo '== Part3: done =='
echo '================='
