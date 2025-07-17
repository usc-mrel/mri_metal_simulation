# MRI Near Metal Simulation
A MATLAB framework for simulating MRI sequences in the presence of metal implants, with a focus on metal artifact reduction techniques

"Open-Source Simulator of Imaging Near Metal at Arbitrary Magnetic Field Strengths" by Kübra Keskin, Ana R. Sanson, Brian A. Hargreaves, Krishna S. Nayak.

## Setup

1. Clone or download this repository
2. Download data from [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16003439.svg)](https://doi.org/10.5281/zenodo.16003439)
3. Place the data inside `./data`
4. Install required MATLAB toolboxes:
	- Statistics and Machine Learning Toolbox
	- Signal Processing Toolbox

## Configuration

Default simulation parameters are defined in `config/getSimulationConfig.m`. These parameters can also be overwritten in the main scripts.

The simulator allows configuration of key MRI parameters including:
- B0 field strength
- Readout bandwidth
- RF bandwidth
- TR, TE
- Number of averages
- Resolution
- Slice thickness
- MRI sequence type
- Number of spectral encodings
- Noise parameters

## Usage

### Single Simulation

1. Change the `phantom_file` parameter inside `main_simulation.m` based on the desired phantom data filename. The filename can be changed based on implant material (e.g., "TiCer" or "Plastic" instead of "CoCr") and phantom resolution (e.g., "02mm" instead of "05mm"):

	```matlab
	phantom_file = dir('./data/hip_combined_phantom*CoCr*05mm*.mat');
	```

2. Customize simulation parameters by editing the default config values or editing overrides in `main_simulation.m`:
   ```matlab
   sim_config.system.B0 = 3.0;             % Field strength (T)
   sim_config.imaging.readBWpix = 600;		% Readout bandwidth (Hz/px)
   sim_config.imaging.rfBW = 1.5;			% RF bandwidth (kHz)
   ```

3. Run simulation:
   ```matlab
   main_simulation.m
   ```

### Parameter Sweeps

1. Change the `phantom_file` parameter inside `main_parameter_sweep.m` based on the desired phantom data filename. The filename can be changed based on implant material (e.g., "TiCer" or "Plastic" instead of "CoCr") and phantom resolution (e.g., "02mm" instead of "05mm"):

	```matlab
	phantom_file = dir('./data/hip_combined_phantom*CoCr*05mm*.mat');
	```
	
2. Customize simulation parameters by editing the default config values or editing overrides in `run_parameter_sweep.m`:
   ```matlab
   sim_config.system.B0 = 3.0;             % Field strength (T)
   sim_config.imaging.readBWpix = 600;		% Readout bandwidth (Hz/px)
   sim_config.imaging.rfBW = 1.5;			% RF bandwidth (kHz)
   ```

3. Define sweep parameters in `main_parameter_sweep.m`:
   ```matlab
   sweep_parameter = 'B0';
   sweep_values = [0.55, 1.5, 3.0, 7.0];
   ```

4. Run the parameter sweep:
   ```matlab
   main_parameter_sweep.m
   ```

The parameter sweep script supports sweeping any of these parameters:
- `B0`: Field strength
- `readBWpix`: Readout bandwidth
- `rfBW`: RF bandwidth
- `Nbins`: Spectral bins
- `seqname`: Sequence
- `TR`: Repetition time
- `TE`: Echo time

See `main_parameter_sweep.m` for examples of different parameter sweep configurations.

### Supported MRI Sequences
The simulator supports the following sequences:
- **TSE** (Turbo Spin Echo)
- **VAT** (View Angle Tilting)
- **SEMAC** (Slice Encoding for Metal Artifact Correction)
- **MAVRIC** (Multi-Acquisition Variable-Resonance Image Combination) 
- **MAVRIC-SL** (MAVRIC-SeLective)

### Simulation Times
**Note**: Simulations can take several minutes to hours depending on the number of slices, spectral bins, chosen sequence, and phantom resolution. 

For quick testing, use the 0.5 mm phantom and simulate TSE or VAT for only a few slices. The parameters set in `main_simulation.m` and `main_parameter_sweep.m` are specifically chosen for rapid testing.

## Outputs

### Simulation Results
Each simulation generates various outputs saved inside a `.mat` file:

**Filename Format**: `{sequence}_{materials}_{B0}T_Nbins{#bins}_readBW{readout_bw}_rfBW{rf_bw}_res{phantom_resolution}_{timestamp}.mat`

**Example**: `SEMAC_CoCr_0.55T_Nbins6_readBW400_rfBW1.0_res0.5_20250716_104931.mat`

### Saved Variables
- `final_im`: Final reconstructed images
- `im`: Raw simulated images (before final reconstruction)
- `params`: Complete simulation parameters used
- `kspace`: K-space data without noise
- `noise_params`: Noise characteristics
- `phantom_config`: Phantom configuration details
- `sim_config`: Original simulation configuration
- `phantom_file`: Source phantom file information

Results are organized as follows:
- `./results/`: Single simulation results
- `./results/parameter_sweep/`: Parameter sweep results


## Directory Structure

```
mri_metal_simulation/
├── config/                      	# Default simulation configuration
├── simulation/
│   ├── sequences/               	# MRI sequence simulation functions
│   ├── reconstruction/          	# Image reconstruction functions
│   ├── helpers/          			# Helper functions for simulation
│   └── utils/          		 	# General utility functions
├── data/              				# Implant phantom data
├── results/              			# Simulation results save folder
│   └── parameter_sweep/          	# Parameter sweep simulation results save folder
├── main_simulation.m            	# Main simulation script
├── main_parameter_sweep.m       	# Main parameter sweep script
└── run_parameter_sweep.m       	# Helper for parameter sweep script
```

## References and Acknowledgements

1. Lu W, Pauly KB, Gold GE, Pauly JM, Hargreaves BA. SEMAC: Slice Encoding for Metal Artifact Correction in MRI. *Magn Reson Med.* 2009;62(1):66-76. doi:10.1002/mrm.21967

2. Koch KM, Lorbiecki JE, Hinks RS, King KF. A multispectral three-dimensional acquisition technique for imaging near metal implants. *Magn Reson Med.* 2009;61(2):381-390. doi:10.1002/mrm.21856

3. Koch KM, Brau AC, Chen W, et al. Imaging near metal with a MAVRIC-SEMAC hybrid. *Magn Reson Med.* 2011;65(1):71-82. doi:10.1002/mrm.22523

4. Koch KM, Hargreaves BA, Pauly KB, Chen W, Gold GE, King KF. Magnetic resonance imaging near metal implants. *J Magn Reson Imaging.* 2010;32(4):773-787. doi:10.1002/jmri.22313

5. 	Hargreaves BA, Worters PW, Pauly KB, Pauly JM, Koch KM, Gold GE. Metal-induced artifacts in MRI. *AJR Am J Roentgenol.* 2011;197(3):547-555. doi:10.2214/AJR.11.7364

6. Shi X, Yoon D, Koch KM, Hargreaves BA. Metallic implant geometry and susceptibility estimation using multispectral B0 field maps. *Magn Reson Med.* 2017;77(6):2402-2413. doi:10.1002/mrm.26313

---

For questions or issues please contact (keskin AT usc DOT edu).


Copyright (c) 2025 Kübra Keskin, Magnetic Resonance Engineering Laboratory. MIT license.
