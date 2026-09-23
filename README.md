# Battery Management: Equivalent Circuit Modeling and SOC/Capacity Estimation

Two related projects from Advanced Energy Storage Systems (ELEC8900-30-R-2025F), University of Windsor, Fall 2025. Both model core functions of an automotive Battery Management System (BMS): terminal voltage prediction under load, impedance characterization, pack scaling, and State of Charge (SOC) tracking.

- **Project 1** (MATLAB): a 2RC equivalent circuit model (ECM) of a single cell, an electrochemical impedance (Nyquist) analysis of that model, and scaling the cell up to a 110-series, 72-parallel (110S72P) EV-scale pack.
- **Project 2** (Simulink): battery capacity estimation from UDDS drive-cycle data using OCV-to-SOC mapping and coulomb counting, then SOC tracking over an HWFET drive cycle using the estimated capacity.

## Battery Simulation Using ECM

Implements the 2RC Thevenin-style equivalent circuit model shown below, with an EMF source, ohmic resistance R0, and two parallel RC branches representing short- and long-timescale polarization.

```
h(k)
EMF --<>-- R0 --+-- R1 --+-- R2 --+--> i(k), v(k)
                |   ||   |   ||   |
                +--C1----+--C2----+
```

The open-circuit voltage (OCV) is modeled with an 8-parameter "Combined+3" function of SOC, and SOC itself is tracked by coulomb counting.

**What's covered:**
- Q1: terminal voltage response to a step current, a +/-1C square wave, and a +/-1C sine wave
- Q2: Nyquist (EIS) plot of the model's complex impedance across 100 log-spaced frequencies (1e-3 to 1e3 Hz), showing the two RC semicircles
- Q3: series/parallel scaling of a single-cell model up to a 110S72P pack (pack resistance and pack capacity)
- Q4: full pack voltage and SOC simulation under UDDS (urban) and HWFET (highway) drive cycles, using a reduced R-int model (EMF + R0 only) for pack-level speed

### Verification

The core `battSIM` and `packSIM` functions were re-implemented from the report's own code and re-run independently in Octave 8.4.0. Every value that the report explicitly reports numerically was reproduced exactly or to the same precision as stated:

| Result | Report | Independently reproduced |
|---|---|---|
| Q1(a) step response direction | "immediate drop" after the discharge step | Confirmed: 3.8253V before, 3.6779V after |
| Q1(b)/(c) voltage range | approx. 3.68 to 3.97 V | 3.6728 to 3.9731 V (square), 3.6802 to 3.9664 V (sine) |
| Q2 Nyquist, high-frequency intercept | approaches R0 = 0.020 ohm | 0.02000 ohm |
| Q2 Nyquist, low-frequency intercept | approaches R0+R1+R2 = 0.040 ohm | 0.03997 ohm |
| Q2 Nyquist, arc height | approx. 7.5e-3 (from the plotted figure) | 0.00753 |
| Q3 pack resistance | 0.03056 ohm | 0.03056 ohm (exact) |
| Q3 pack capacity | 288 Ah | 288.0 Ah (exact) |

Q4 (the UDDS/HWFET pack drive-cycle voltage and SOC curves) uses `UDDScurrent.mat` and `HWFETcurrent.mat`, standard EPA drive-cycle current traces supplied by the course. Those files aren't included in this repo, so Q4 is documented from the report's own figures rather than independently re-run here. The `packSIM` function itself is verified (it's the same function used correctly for the Q3 pack math above).

### Files

- `battSIM.m`: single-cell 2RC ECM terminal voltage, given a current profile
- `packSIM.m`: pack-level R-int model (EMF + R0 only) for a given series/parallel configuration
- `plotVI.m`: current/voltage plotting helper
- `main_analysis.m`: runs Q1 through Q3 end to end; Q4 is included as commented reference code since its data files aren't bundled here

## Battery Capacity Estimation and SOC Tracking

A Simulink implementation of the same underlying BMS functions, built as block diagrams rather than a MATLAB script:

- **Capacity estimation** (from UDDS data): detects two rest periods (current = 0 for >=150s), latches SOC1 and SOC2 from the stabilized OCV at each rest using `SOC = k0 + k1*V`, integrates current over the discharge between them to get coulombs, and computes capacity as `Q = C / (SOC2 - SOC1)`.
- **SOC tracking** (over HWFET data): uses the capacity from above and coulomb counting (`SOC(t) = SOC(0) + (1/3600Q) * integral of I dt`) to track SOC through a full highway drive cycle.

Reported results: SOC1 = 0.50, SOC2 = 0.37, C = 7.2e4 C, giving Q = 153.8 Ah; HWFET SOC then rises from 0.50 to a plateau near 0.62-0.63 as the mostly-regenerative HWFET profile nets a charging effect over the cycle.

### Verification

`.slx` files can't be executed outside MATLAB/Simulink, which isn't available in the environment this repo was built in. The file was checked structurally instead: it parses as well-formed, uncorrupted Simulink R2024a XML, and its block hierarchy (a top-level model containing a "Capacity Estimation" subsystem with a nested "Calculate Capacity" block, plus a separate "SOC calculation" subsystem) matches the structure documented in the project report. The numeric results above are taken from the report's own scope captures, not independently re-simulated.

### Files

- [`proj2_capacity_soc.slx`](https://lawazislam.com/assets/downloads/battery-management-ecm-soc/proj2_capacity_soc.slx): the Simulink model (R2024a). Hosted on my site rather than in this repo, GitHub's file upload doesn't handle this binary format reliably.

## Reports

Full write-ups with all figures, equations, and derivations for both projects are linked from the portfolio site: [lawazislam.com](https://lawazislam.com).

## Skills demonstrated

Battery management systems, equivalent circuit modeling, coulomb counting, OCV-SOC mapping, electrochemical impedance spectroscopy (Nyquist analysis), series/parallel pack scaling, MATLAB, Simulink.
