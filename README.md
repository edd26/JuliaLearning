# JuliaLearning

JuliaLearning is a Julia repository which deals with following subjects: image processing, video processing and computational homology.

## Dependencies
In the file "dependencies.txt" all packages used across all of the scripts are listed. They can be added to Julia by typing
```
]add PackageToInstall
```


## Usage
In the repository there are few scripts which can be run as standalone scripts. Those are:

* TestingPairwiseCorrelationmatrix.jl - script for computing pairwise correlation matrix (PCM). It allows to:
  * set of input videos for which the computations are done,
  * set the method for choosing regions for which PCM is computed,
  * set the set of tau parameter (thau is the shift of the signals while corss-correltaion of two signals is computed),
  * set the number of point for which PCM is computed
* video_generation.jl - script for generation of new videos from the existing videos;
* gif_generation.jl - script for gif generation;
* clique_top_in_Julia.jl - script for running MATLAB library "clique-top" as well as Julia bersion of this library;
* menu.jl- script for running terminal menu which allows:
  * running TestingPairwiseCorrelationmatrix.jl script
  * adjustment of the parameters used in the above script.

## Local packages
In this repository there are few packages which contain functions  which are necessary to run above scripts. Those are:
* GifGenerator.jl - package in which
* VideoProcessing.jl - package in which functions for loading, processing and saving video are stored
* MatrixToolbox.jl - package for creation of geometric, random and shuffled matrix; it also allows to save/load a matrix to/from a file, generate ordering matrix and generate set of graphs based on the ordering matrix
* Settings.jl - file stores parameters used by TestingPairwiseCorrelationmatrix.jl script. It also creates a results folder and stores information about paths to the folders in which videos are sotred.

## External libraries
In this repository MATLAB "clique-top" library is included. It is used for computation of the persistent homology. Also, folder "clique_top_Julia" contains the same library but (partially) rewritten in Julia. Although great care was taken to provide exactly the same functionality as the MATLAB version, there is no guarantee that this was achieved.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[GNU General Public License](https://choosealicense.com/licenses/gpl-3.0/)
