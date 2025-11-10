LLM-DSE
=======

```
@misc{wang2025llmdsesearchingacceleratorparameters,
      title={LLM-DSE: Searching Accelerator Parameters with LLM Agents}, 
      author={Hanyu Wang and Xinrui Wu and Zijian Ding and Su Zheng and Chengyue Wang and Tony Nowatzki and Yizhou Sun and Jason Cong},
      year={2025},
      eprint={2505.12188},
      archivePrefix={arXiv},
      primaryClass={cs.AR},
      url={https://arxiv.org/abs/2505.12188}, 
}
```

Getting Started
---------------

**Step 1** Preparation:
Ensure that you have 300 GB of free space on your device.
- Docker: https://docs.docker.com/engine/install/
- AMD/Xilinx Vitis HLS: https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vitis.html

To reproduce the code, you need to pull and run the docker from VAST DSE-for-HLS.
`https://github.com/UCLA-VAST/DSE-for-HLS/tree/main/example`

```bash
./merlin.sh
Apptainer> source run.sh
```


**Step 2** Before running the script, you need to put the OPENAI API key in the `.env` file and specify a work dir (all itermediate results will be stored there).
```bash
cp .env_example .env
```

**Step 3** Then, you can run the script with the following command:
```bash
pip install -r requirements.txt
python main.py --benchmark 3mm --folder ../data/pack1
```

**A detailed explanation of environment setup**

详细的中文指导请参考SETUP_FOR_NEW_USER.md

Running HLS evaluation requires two tools: Merlin and Vitis HLS. For this project, please download Vitis HLS version 2025.1. After installing Merlin and Vitis HLS, the following two files can help you setup the environment at every time you run. Please see the "TODO"s in these two files, which mark the places you need to modify to your own paths and commands.

- merlin.sh: It starts the Merlin Docker image. Please see "TODO"s and instructions inside the file. 
- setup.sh: Inside the Merlin docker, it sets up the necessary environment paths. Please see "TODO"s and instructions inside the file. **There are many tricky parts for environment setup in this file. Please read the instructions carefully.**

To run the program, we first run:

```bash
source ./merlin.sh
```

to enter the docker. Then, **inside the docker**, we run:

```bash
source ./setup.sh
```

Then, please run "python --version" to confirm that the default python has been changed to python 2. Then, run the folloiwng commands. Make sure to use "python3 main.py", because setup.sh already sets the default "python" to be python 2.

```bash
cd src
python3 main.py --benchmark 3mm --folder ../data/pack1
```


Troubleshooting
---------------

> Can't install Vitis and Merlin Compiler?

Toggle the `ENABLE_DATABASE_LOOKUP` flag in `config.py` to `True` and run the script again. This will look up the compilation history in the database and is likely to skip the compilation step.

> Can't find it in the database?

Toggle the `DEBUG_MERLIN` flag in `config.py` to `True` and run the script again. This will skip the compilation step and use a fake backend. 

> No OPENAI API key or no budget?

Toggle the `AUTO_<XX>` flag in `config.py` (replace `XX` with the agent names) to bypass the agent using heuristics. This will skip the agent and use a fake backend.
