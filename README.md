# ZKPチュートリアル2

このプロジェクトは、ゼロ知識証明（ZKP）の基本的な概念と実装を学ぶためのチュートリアルです。
主に [Circom](https://docs.circom.io/) と [SnarkJS](https://github.com/iden3/snarkjs) を使用しています。

## 目次

- [はじめに](#はじめに)
- [前提条件](#前提条件)
- [インストール](#インストール)
- [使用方法](#使用方法)
  - [1-回路のコンパイル](#1-回路のコンパイル)
  - [2-信頼できるセットアップ-powers-of-tau](#2-信頼できるセットアップ-powers-of-tau)
  - [3-フェーズ2セットアップ](#3-フェーズ2セットアップ)
  - [4-Witnessの計算](#4-witnessの計算)
  - [5-証明の生成](#5-証明の生成)
  - [6-証明の検証](#6-証明の検証)
  - [7-solidity検証者の生成](#7-solidity検証者の生成)
- [生成されるファイル](#生成されるファイル)
- [貢献](#貢献)
- [ライセンス](#ライセンス)

## はじめに

これは [Writing circuits](https://github.com/iden3/circom/blob/de2212a7aa6a070c636cc73382a3deba8c658ad5/mkdocs/docs/getting-started/writing-circuits.md) にある、

* `A*B + C = 0`

が、circom での制約で

* `c <== a * b`

になることに納得できずに確認するために作ったリポジトリである。  
input.json にそれぞれの値を入れると、`a * b === c` のチェックをする。

あとで気付いたが、`A*B + C = 0` と circom の制約が一致するとは書いていないし、
そもそも `A*B + C = 0` をどこかに与えるわけでもないので確認のしようがないのだった。


## 前提条件

プロジェクトを実行する前に、以下のものがインストールされていることを確認してください。

- [Node.js](https://nodejs.org/) (バージョン16以上を推奨)
- npm または yarn
- [Circom](https://docs.circom.io/getting-started/installation/)
- [SnarkJS](https://github.com/iden3/snarkjs#installation) (通常、プロジェクトの依存関係としてインストールされます)

## インストール

プロジェクトの依存関係をインストールするには、リポジトリをクローンして次のコマンドを実行します。

```bash
git clone <リポジトリのURL>
cd zkp-tutorial2
npm install
# または
# yarn install
```

## 使用方法

以下は、ZKPの一般的なワークフローと関連するSnarkJSコマンドの例です。
実際のファイル名やパスは、プロジェクトの構成に合わせて調整してください。
（例: `circuit.circom` は実際の回路ファイル名に置き換えてください。）

### 1. 回路のコンパイル

Circom回路（例: `circuit.circom`）をコンパイルして、R1CS、WebAssembly（Wasm）、シンボルファイルを生成します。

```bash
circom circuit.circom --r1cs --wasm --sym -o build
```

### 2. 信頼できるセットアップ (Powers of Tau)

Groth16セットアップのフェーズ1（Powers of Tau）を実行します。これは回路に依存しないステップです。
既存の `ptau` ファイルを使用することもできます。

```bash
# 新しいPowers of Tauセレモニーを開始
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
# 貢献 (実際には複数の貢献が必要です)
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v -e="random text"
# フェーズ2の準備
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
```

### 3. フェーズ2セットアップ

回路固有のセットアップ（フェーズ2）を実行して、証明キー (`.zkey`) と検証キー (`verification_key.json`) を生成します。

```bash
snarkjs groth16 setup build/circuit.r1cs pot12_final.ptau circuit_0000.zkey
# 貢献 (オプションですが、本番環境では推奨されます)
snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="1st Contributor Name" -v -e="random entropy"
# 検証キーのエクスポート
snarkjs zkey export verificationkey circuit_0001.zkey verification_key.json
```

### 4. Witnessの計算

入力ファイル（例: `input.json`）とコンパイルされたWasmを使用してWitnessを計算します。

```bash
# build/circuit_js/generate_witness.js が circom によって生成されます
node build/circuit_js/generate_witness.js build/circuit.wasm input.json witness.wtns
```

### 5. 証明の生成

計算されたWitnessと証明キーを使用して、ゼロ知識証明を生成します。

```bash
snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json
```

### 6. 証明の検証

生成された証明、公開情報、検証キーを使用して証明を検証します。

```bash
snarkjs groth16 verify verification_key.json public.json proof.json
```

### 7. Solidity検証者の生成

オンチェーンで証明を検証するためのSolidityスマートコントラクトを生成します。

```bash
snarkjs zkey export solidityverifier circuit_0001.zkey verifier.sol
```

## 生成されるファイル

このプロジェクトでは、ビルドプロセス中にいくつかの中間ファイルや最終成果物が生成されます。
これらの多くは `.gitignore` ファイルに記載されており、バージョン管理システムからは除外されています。

- `**/node_modules/`
- `*.zkey` (証明キー、最終キー)
- `*.ptau` (Powers of Tauファイル)
- `*.r1cs` (Rank-1 Constraint Systemファイル)
- `*.sym` (シンボルファイル)
- `public.json` (公開入力と出力)
- `verification_key.json` (検証キー)
- `proof.json` (生成された証明)
- `witness.wtns` (Witnessファイル)
- `verifier.sol` (Solidity検証コントラクト)

## 貢献

プルリクエストを歓迎します。大きな変更については、まずissueを開いて変更内容について議論してください。

## ライセンス

このプロジェクトは [ライセンス名を入力] ライセンスの下で公開されています。 (例: MIT)