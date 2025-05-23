// https://github.com/iden3/circom/blob/de2212a7aa6a070c636cc73382a3deba8c658ad5/mkdocs/docs/getting-started/writing-circuits.md
pragma circom 2.0.0;

/*This circuit template checks that c is the multiplication of a and b.*/

template Multiplier2() {
   // Declaration of signals.
   signal input a;
   signal input b;
   signal output c;

   // Constraints.
   c <== a * b;
}

template Main() {
    signal input a;
    signal input b;
    signal input c;

    component mul = Multiplier2();
    mul.a <== a;
    mul.b <== b;

    c === mul.c;
}

component main {public [a, b]} = Main();
