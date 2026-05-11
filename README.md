# 🌐 DOT-Framework: Principled Distributional Framework for Evolutionary Optimization via Optimal Transport

![MATLAB](https://img.shields.io/badge/MATLAB-R2021a%2B-orange)
![Python](https://img.shields.io/badge/Python-3.7%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%2064--bit-lightgrey)
![License](https://img.shields.io/badge/License-Check%20Third--Party%20Notices-yellow)

---

## 🚀 Download and Install

📦 **Download DOT-NAS-Open-Policy**:  
https://drive.google.com/file/d/1fuAAtXmRo9brYivCDiFQa_cNZvIBte1R/view?usp=drive_link

📦 **Download DOT-WireMask-Open-Policy**:  
https://drive.google.com/file/d/1f-7N3JYic4TNkR7VZtAKor1-hXGsZXkE/view?usp=drive_link

This repository provides the official implementation of **DOT**, a distributional optimization framework based on optimal transport.

The codebase contains three open-policy implementations:

- 🔹 **DOT-Open-Policy**: MATLAB implementation for continuous optimization on CEC2017 functions.
- 🔹 **DOT-NAS-Open-Policy**: MATLAB/Python implementation for NAS101 neural architecture search.
- 🔹 **DOT-WireMask-Open-Policy**: Python implementation for VLSI macro placement on ISPD2005.

---
---
## 📁 Repository Structure

```text
.
|-- Principled_distributional_framework_for_evolutionary_optimization_via_optimal_transport.pdf
|-- DOT-Open-Policy/
|   |-- OpTr_by_SinkHorn.m
|   |-- DisOT_ProbMeasure.m
|   |-- Sinkhorn_OTcomputing.m
|   |-- cec17_func.cpp
|   |-- cec17_func.mexw64
|   |-- input_data/
|   `-- Test_Figures/
|-- DOT-NAS-Open-Policy/
|   |-- OpTr_by_SinkHorn.m
|   |-- DisOT_ProbMeasure.m
|   |-- NASBenchDaemon.m
|   |-- nasbench_daemon.py
|   |-- data/
|   |   `-- nasbench_only108.tfrecord
|   `-- README.md
`-- DOT-WireMask-Open-Policy/
    |-- DOT.py
    |-- RS.py
    |-- BO.py
    |-- optimal_transport_search.py
    |-- place_db.py
    |-- utils.py
    |-- common.py
    |-- benchmark/
    |-- result/
    `-- matlab/
        `-- +wiremask/
            `-- Bridge.m
```

---
## 🧩 System Requirements

The current implementation is mainly tested under a Windows 64-bit environment.

| Component | Requirement |
|---|---|
| MATLAB | Required for `DOT-Open-Policy` and `DOT-NAS-Open-Policy` |
| Python | Required for `DOT-NAS-Open-Policy` and `DOT-WireMask-Open-Policy` |
| NASBench Python version | Python 3.7 recommended |
| NASBench TensorFlow version | TensorFlow 1.15.0 |
| MATLAB toolbox | Statistics and Machine Learning Toolbox recommended |
| GPU | Not required for the main DOT macro-placement entrypoint |

### 📝 Notes

- `DOT-Open-Policy` includes a Windows MATLAB MEX file: `cec17_func.mexw64`.
- For non-Windows systems, compile `cec17_func.cpp` locally.
- `DOT-NAS-Open-Policy` uses a persistent Python NASBench daemon.
- `BO.py` in `DOT-WireMask-Open-Policy` may use `device="cuda"` and should be changed to CPU if no CUDA GPU is available.

---

## ⚙️ Installation

### 🔸 1. DOT-Open-Policy

On Windows, the included MEX file can be used directly.

```bash
cd DOT-Open-Policy
matlab -batch "OpTr_by_SinkHorn"
```

For non-Windows MATLAB environments, compile the CEC2017 objective first:

```matlab
mex cec17_func.cpp
```

---

### 🔸 2. DOT-NAS-Open-Policy

Run the following commands from `DOT-NAS-Open-Policy`.

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

uv venv --python 3.7
.venv\Scripts\activate.bat

uv pip install "tensorflow==1.15.0"
uv pip install "protobuf==3.20.3"
uv pip install -e .
```

The default MATLAB daemon paths are:

```text
.venv/Scripts/python.exe
data/nasbench_only108.tfrecord
```

They can be changed when constructing `NASBenchDaemon`:

```matlab
nb = NASBenchDaemon( ...
    'PythonPath', '.venv/Scripts/python.exe', ...
    'DatasetPath', 'data/nasbench_only108.tfrecord' ...
);
```

---

### 🔸 3. DOT-WireMask-Open-Policy

Run the following commands from `DOT-WireMask-Open-Policy`.

```powershell
python -m venv .venv
.venv\Scripts\activate

python -m pip install --upgrade pip
pip install -r requirements.txt
pip install -e TuRBO
```

The benchmark directory should contain ISPD2005 circuits such as:

```text
adaptec1
adaptec2
adaptec3
adaptec4
bigblue1
bigblue2
bigblue3
bigblue4
```

---

## 🏃 Quick Start

### 📌 CEC2017 Continuous Optimization

```bash
cd DOT-Open-Policy
matlab -batch "OpTr_by_SinkHorn"
```

### 📌 NASBench-101 Daemon Test

```bash
cd DOT-NAS-Open-Policy
matlab -batch "speed_demo"
```

### 📌 NASBench-101 DOT Search

```bash
cd DOT-NAS-Open-Policy
matlab -batch "OpTr_by_SinkHorn"
```

### 📌 WireMask DOT Macro Placement

```bash
cd DOT-WireMask-Open-Policy
python DOT.py --dataset adaptec3 --seed 2025 --init_round 30 --stop_round 171
```

---

## 🔬 DOT-Open-Policy: CEC2017 Optimization

`DOT-Open-Policy` runs DOT on CEC2017 continuous benchmark functions.

Default configuration in `OpTr_by_SinkHorn.m`:

```matlab
dimensions = [2, 10, 30, 50, 100];
Particle_number = [30, 30, 50, 100, 100];
Max_iteration = [2500, 3500, 6000, 8000, 10000];
ThreShold = [100, 250, 450, 550, 790];
Skip = [0, 240, 1400, 4800, 9800];

SH_max_runs = 50;
lam = 0.0015;
runtimes = 30;

tes = 4;  % selects 50D
```

Run:

```bash
cd DOT-Open-Policy
matlab -batch "OpTr_by_SinkHorn"
```

Typical outputs:

```text
DOT_CEC2017_res_<D>D05_Func1_17_<Run>Run.xlsx
DOT_<D>_Data/*.mat
Test_Figures/
```

For a short test, set `runtimes = 1` and restrict the function set in `OpTr_by_SinkHorn.m`.

---

## 🧠 DOT-NAS-Open-Policy: NASBench-101 Search

Run environment test:

```bash
cd DOT-NAS-Open-Policy
matlab -batch "speed_demo"
```

Run DOT search:

```bash
cd DOT-NAS-Open-Policy
matlab -batch "OpTr_by_SinkHorn"
```

Typical outputs:

```text
DOT_NAS_Bench101_26D05_Func1_<Run>Run.xlsx
Test_Figures/*.fig
```

---

## 🏗️ DOT-WireMask-Open-Policy: VLSI Macro Placement

| Dataset | grid_num | grid_size |
|---|---:|---:|
| `adaptec1` | 160 | 72 |
| `adaptec2` | 158 | 96 |
| `adaptec3` | 113 | 216 |
| `adaptec4` | 108 | 216 |
| `bigblue1` | 160 | 72 |
| `bigblue2` | 376 | 50 |
| `bigblue3` | 234 | 119 |
| `bigblue4` | 273 | 119 |

Run DOT placement:

```bash
cd DOT-WireMask-Open-Policy
python DOT.py --dataset adaptec3 --seed 2025 --init_round 30 --stop_round 171
```

Typical `stop_round` values:

| Dataset | stop_round |
|---|---:|
| `bigblue1` | 239 |
| `bigblue3` | 28 |
| `bigblue4` | 3 |
| `adaptec1` | 116 |
| `adaptec2` | 117 |
| `adaptec3` | 171 |
| `adaptec4` | 88 |

Typical outputs:

```text
result/DOT/curve/<dataset>_seed_<seed>.csv
result/DOT/placement/<dataset>_seed_<seed>.csv
result/Random/
result/BO/
```


## 🛠️ Troubleshooting

- ⚠️ If MATLAB cannot find `cec17_func`, run from `DOT-Open-Policy` or compile `cec17_func.cpp`.
- ⚠️ If `xlswrite` fails, replace it with `writematrix`, `writecell`, or `writetable`.
- ⚠️ If `NASBenchDaemon` cannot find Python, pass `PythonPath` explicitly.
- ⚠️ If `NASBenchDaemon` cannot find the dataset, pass `DatasetPath` explicitly.
- ⚠️ If TensorFlow installation fails, use Python 3.7 with TensorFlow 1.15.0.
- ⚠️ If `BO.py` fails on CPU-only machines, change `device="cuda"` to `device="cpu"`.

---

## 📄 License

Please check and retain all third-party license notices before redistribution.

Known license notes:

- `DOT-NAS-Open-Policy` includes NASBench code under the Apache License 2.0.
- `DOT-WireMask-Open-Policy` currently has no local license file in the provided project description.
- `DOT-Open-Policy` currently has no local license file in the provided project description.


---
