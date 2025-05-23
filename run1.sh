#!/bin/bash -e

echo '===================='
echo '== Part1: Phase 1 =='
echo '===================='
echo

# clean
rm -f pot14_*.ptau

# phase 1

# new
npx snarkjs powersoftau new bn128 14 pot14_0000.ptau -v

# contribute to the Phase 1 ceremony
npx snarkjs powersoftau contribute pot14_0000.ptau pot14_0001.ptau --name="First contribution" -v -e="random text 1"
npx snarkjs powersoftau contribute pot14_0001.ptau pot14_0002.ptau --name="Second contribution" -v -e="random text 2"
npx snarkjs powersoftau contribute pot14_0002.ptau pot14_0003.ptau --name="Third contribution" -v -e="random text 3"

# apply random beacon
npx snarkjs powersoftau beacon pot14_0003.ptau pot14_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

# prepare phase 2(several minutes)
npx snarkjs powersoftau prepare phase2 pot14_beacon.ptau pot14_final.ptau -v

# verify the final ptau
npx snarkjs powersoftau verify pot14_final.ptau

echo
echo '================='
echo '== Part1: done =='
echo '================='
