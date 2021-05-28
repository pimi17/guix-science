;;;
;;; Copyright © 2016-2021 Roel Janssen <roel@gnu.org>
;;;
;;; This program is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(define-module (guix-science packages bioinformatics)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bioinformatics)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages check)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cran)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages java)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages parallel)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages perl-check)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages statistics)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages time)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages web)
  #:use-module (gnu packages wget)
  #:use-module (gnu packages xml)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system perl)
  #:use-module (guix build-system python)
  #:use-module (guix build-system r)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix-science packages grid-engine))

(define-public spades
  (package
   (name "spades")
   (version "3.15.2")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "http://cab.spbu.ru/files/release"
                  version "/SPAdes-" version ".tar.gz"))
            (sha256
             (base32 "03cxz4m1n4rc81lqb4p1pz2ammms7f31wvi4daywfkc13aal6fz9"))))
   (build-system cmake-build-system)
   ;; Reported under section 2 "Installation", "SPAdes requires a 64-bit
   ;; system": http://cab.spbu.ru/files/release3.10.1/manual.html
   (supported-systems '("x86_64-linux"))
   (arguments
    `(#:tests? #f ; There is no test target.
      #:phases
      (modify-phases %standard-phases
        (add-before 'configure 'move-to-source-dir
          (lambda _
            (chdir "src"))))))
   ;; TODO:  While this build works fine, SPAdes bundles samtools, bwa, and
   ;; boost.  These packages are also available in GNU Guix, so we should
   ;; unbundle them.
   (inputs
    `(("bzip2" ,bzip2)
      ("zlib" ,zlib)
      ("perl" ,perl)
      ("python-2" ,python-2)))
   (home-page "http://cab.spbu.ru/software/spades")
   (synopsis "Genome assembly toolkit")
   (description "SPAdes is an assembly toolkit containing various assembly
pipelines.")
   (license license:gpl2)))

(define-public assembly-stats
  (package
   (name "assembly-stats")
   (version "1.0.1")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/sanger-pathogens/assembly-stats/archive/v"
                  version ".tar.gz"))
            (file-name (string-append name "-" version ".tar.gz"))
            (sha256
             (base32 "0xc5ppmcs09d16f062nbb0mdb0cnfhbnkp0arlxnfi6jli6n3gh2"))))
   (build-system cmake-build-system)
   (arguments
    `(#:configure-flags (list (string-append
                               "-DINSTALL_DIR:PATH="
                               %output
                               "/bin"))))
   (home-page "https://github.com/sanger-pathogens")
   (synopsis "Tool to extract assembly statistics from FASTA and FASTQ files")
   (description "This package provides a tool to extract assembly statistics
from FASTA and FASTQ files.")
   (license license:gpl3)))

(define-public fastq-tools
  (package
   (name "fastq-tools")
   (version "0.8")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "http://homes.cs.washington.edu/~dcjones/fastq-tools/"
                  name "-" version ".tar.gz"))
            (sha256
             (base32
              "0jz1y40fs3x31bw10097a1nhm0vhbsyxmd4n7dwdsl275sc9l1nz"))))
   (build-system gnu-build-system)
   (arguments `(#:tests? #f))
   (inputs
    `(("pcre" ,pcre "bin")
      ("zlib" ,zlib)))
   (home-page "https://homes.cs.washington.edu/~dcjones/fastq-tools/")
   (synopsis "Tools to work with FASTQ files")
   (description "This packages provides a collection of small and efficient
programs for performing some common and uncommon tasks with FASTQ files.")
   (license license:gpl3)))

(define-public fast5
  (package
   (name "fast5")
   (version "0.6.5")
   (source (origin
            (method url-fetch)
            (uri (string-append "https://github.com/mateidavid/fast5/archive/v"
                                version ".tar.gz"))
            (sha256
             (base32 "06pfg2ldra5g6d14xrxprn35y994w44g0zik2d7npddd0wncxcgq"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f ; There are no tests.
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (replace 'build
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (setenv "HDF5_INCLUDE_DIR" (string-append (assoc-ref inputs "hdf5") "/include"))
            (setenv "HDF5_LIB_DIR" (string-append (assoc-ref inputs "hdf5") "/lib"))
            ;; TODO: Check for return value.
            (substitute* "python/Makefile"
              (("install: check_virtualenv") "install:"))
            (system* "make" "-C" "python" "install")))
        (replace 'install
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (let* ((out (assoc-ref outputs "out"))
                   (python (assoc-ref inputs "python"))
                   (site-dir (string-append out "/lib/python3.6"
                                            "/site-packages/fast5/"))
                   (bin (string-append out "/bin"))
                   (include (string-append out "/include")))
              (mkdir-p site-dir)
              (mkdir-p bin)
              (install-file "python/fast5/fast5.pyx" site-dir)
              (install-file "python/bin/f5ls" bin)
              (install-file "python/bin/f5pack" bin)

              ;; Patch /usr/bin/env.
              (substitute* (list (string-append bin "/f5ls")
                                 (string-append bin "/f5pack"))
                (("/usr/bin/env python") (string-append python "/bin/python3")))

              ;; Wrap the environments of main programs so that
              ;; these work as expected.
              (wrap-program (string-append bin "/f5ls")
                `("PYTHONPATH" ":" prefix (,bin ,(getenv "PYTHONPATH")
                                                ,site-dir)))
              (wrap-program (string-append bin "/f5pack")
                `("PYTHONPATH" ":" prefix (,bin ,(getenv "PYTHONPATH")
                                                ,site-dir)))

              (for-each (lambda (file)
                          (install-file file include))
                        (find-files "src")))
            #t)))))
   (native-inputs
    `(("which" ,which)))
   (inputs
    `(("python" ,python-3)
      ("python-setuptools" ,python-setuptools)
      ("python-cython" ,python-cython)
      ("hdf5" ,hdf5)
      ("gcc" ,gcc-9)))
   (propagated-inputs
    `(("python-dateutil" ,python-dateutil)))
   (home-page "https://github.com/mateidavid/fast5")
   (synopsis "Library for accessing Oxford Nanopore sequencing data")
   (description "This package provides a lightweight C++ library for accessing
Oxford Nanopore Technologies sequencing data.")
   (license license:expat)))

(define-public fastqc-bin
  (package
    (name "fastqc")
    (version "0.11.9")
    (source (origin
      (method url-fetch)
      (uri (string-append
            "http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v"
            version ".zip"))
      (sha256
       (base32 "0s8k6ac68xx6bsivkzcc4qcb57shav2wl5xp4l1y967pdqbhll8m"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f ; No tests for binary release.
       #:phases
       (modify-phases %standard-phases
         (delete 'configure) ; No configure phase for binary release.
         (delete 'build) ; No build phase for binary release.
         (replace 'install
           (lambda _
             (let* ((out (assoc-ref %outputs "out"))
                    (bin (string-append out "/bin"))
                    (create-and-copy
                     (lambda (dir)
                       (mkdir (string-append bin "/" dir))
                       (copy-recursively dir (string-append bin "/" dir)))))
               (install-file "cisd-jhdf5.jar" bin)
               (install-file "jbzip2-0.9.jar" bin)
               (install-file "sam-1.103.jar" bin)
               (map create-and-copy '("net" "org" "uk" "Templates" "Help"
                                      "Configuration"))
               (install-file "fastqc" bin)
               ;; Make the script executable.
               (chmod (string-append bin "/fastqc") #o555)))))))
    (propagated-inputs
     `(("perl" ,perl) ; Used for a runner script for the Java program.
       ("jdk" ,icedtea-7)))
    (native-inputs
     `(("unzip" ,unzip)))
    (home-page "http://www.bioinformatics.babraham.ac.uk/projects/fastqc/")
    (synopsis "A quality control tool for high throughput sequence data")
    (description
     "FastQC aims to provide a QC report which can spot problems which originate
either in the sequencer or in the starting library material.  It can either run
as a stand alone interactive application for the immediate analysis of small
numbers of FastQ files, or it can be run in a non-interactive mode where it
would be suitable for integrating into a larger analysis pipeline for the
systematic processing of large numbers of files.")
    ;; FastQC is licensed GPLv3+, but one of its dependencies (JHDF5) is
    ;; licensed ASL2.0.
    (license (list license:gpl3+ license:asl2.0))))

(define-public freec
  (package
    (name "freec")
    (version "11.6")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/BoevaLab/FREEC/archive/v"
                           version ".tar.gz"))
       (file-name (string-append "freec-" version ".tar.gz"))
       (sha256
        (base32 "0d0prnix9cpdk5df9fpmf1224kxjgvl809s1rwhffdhjl234ymin"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-before 'build 'move-to-src-dir
           (lambda _
             (chdir "src")))
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (share (string-append out "/share/freec")))
               (mkdir-p bin)
               (mkdir-p share)
               (copy-recursively "../scripts" share)
               (install-file "freec" bin)))))))
    (inputs
     `(("perl" ,perl)))
    (propagated-inputs
     `(("r-rtracklayer" ,r-rtracklayer)))
    (home-page "http://bioinfo-out.curie.fr/projects/freec/")
    (synopsis "Tool for detection of copy-number changes and allelic imbalances
(including LOH) using deep-sequencing data")
    (description "Control-FREEC automatically computes, normalizes, segments
copy number and beta allele frequency (BAF) profiles, then calls copy number
alterations and LOH.  The control (matched normal) sample is optional for whole
genome sequencing data but mandatory for whole exome or targeted sequencing
data.  For whole genome sequencing data analysis, the program can also use
mappability data (files created by GEM).")
    (license license:gpl2+)))

(define-public python-pyvcf
  (package
    (name "python-pyvcf")
    (version "0.6.8")
    (source (origin
              (method url-fetch)
              (uri (pypi-uri "PyVCF" version))
              (sha256
               (base32
                "1ngryr12d3izmhmwplc46xhyj9i7yhrpm90xnsd2578p7m8p5n79"))))
    (build-system python-build-system)
    (arguments `(#:tests? #f)) ; The tests cannot find its files.
    (propagated-inputs
     `(("python-setuptools" ,python-setuptools)
       ("python-psutil" ,python-psutil)))
    (home-page "https://github.com/jamescasbon/PyVCF")
    (synopsis "Variant Call Format parser for Python")
    (description "This package provides a Variant Call Format (VCF) parser
for Python.")
    (license license:expat)))

;; This is a dependency for manta.
(define-public pyflow
  (package
    (name "pyflow")
    (version "1.1.12")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/Illumina/pyflow/releases/download/v"
                    version "/pyflow-" version ".tar.gz"))
              (sha256
               (base32
                "14zw8kf24c7xiwxg0q98s2dlifc4fzrjwzx1dhb99zvdihnx5bg7"))))
    (build-system python-build-system)
    (arguments `(#:tests? #f)) ; There is no test suite.
    (home-page "https://illumina.github.io/pyflow")
    (synopsis "Tool to manage tasks in the context of a task dependency graph")
    (description "This package is a Python module to manage tasks in the context
of a task dependency graph.  It has some similarities to make.")
    (license license:bsd-2)))

(define-public pyflow-2
  (package-with-python2 pyflow))

(define-public manta-1.6.0
  (package
   (name "manta")
   (version "1.6.0")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/Illumina/manta/archive/v"
                  version ".tar.gz"))
            (file-name (string-append name "-" version ".tar.gz"))
            (sha256
              (base32 "08b440hrxm5v5ac2iw76iaa398mgj6qa7yc1cfqjrfd3jm57rkkn"))
            (patches (list (search-patch "manta-relax-dependency-checking.patch")))))
   (build-system cmake-build-system)
   (arguments
    `(#:phases
      (modify-phases %standard-phases
        ;; The 'manta-relax-dependency-checking.patch' sets the samtools path to
        ;; '/usr/bin'.  This allows us to substitute it for the actual path
        ;; of samtools in the store.
        (add-before 'configure 'patch-samtools-path
          (lambda* (#:key inputs #:allow-other-keys)
            (substitute* "redist/CMakeLists.txt"
             (("set\\(SAMTOOLS_DIR \"/usr/bin\"\\)")
              (string-append "set(SAMTOOLS_DIR \""
                             (assoc-ref inputs "samtools") "/bin\")")))
            #t))
        (add-before 'configure 'fix-tool-paths
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (substitute* "src/python/lib/mantaOptions.py"
              (("bgzipBin=joinFile\\(libexecDir,exeFile\\(\"bgzip\"\\)\\)")
               (string-append "bgzipBin=\"" (string-append
                                             (assoc-ref inputs "htslib")
                                             "/bin/bgzip") "\""))
              (("htsfileBin=joinFile\\(libexecDir,exeFile\\(\"htsfile\"\\)\\)")
               (string-append "htsfileBin=\"" (string-append
                                               (assoc-ref inputs "htslib")
                                               "/bin/htsfile") "\""))
              (("tabixBin=joinFile\\(libexecDir,exeFile\\(\"tabix\"\\)\\)")
               (string-append "tabixBin=\"" (string-append
                                           (assoc-ref inputs "htslib")
                                           "/bin/tabix" "\"")))
              (("samtoolsBin=joinFile\\(libexecDir,exeFile\\(\"samtools\"\\)\\)")
               (string-append "samtoolsBin=\"" (string-append
                                              (assoc-ref inputs "samtools")
                                              "/bin/samtools" "\""))))
            (substitute* '("src/demo/runMantaWorkflowDemo.py"
                           "src/python/bin/configManta.py"
                           "src/python/lib/makeRunScript.py"
                           "src/python/libexec/cat.py"
                           "src/python/libexec/convertInversion.py"
                           "src/python/libexec/denovo_scoring.py"
                           "src/python/libexec/extractSmallIndelCandidates.py"
                           "src/python/libexec/mergeBam.py"
                           "src/python/libexec/mergeChromDepth.py"
                           "src/python/libexec/ploidyFilter.py"
                           "src/python/libexec/sortBam.py"
                           "src/python/libexec/sortEdgeLogs.py"
                           "src/python/libexec/sortVcf.py"
                           "src/python/libexec/updateSampleFTFilter.py"
                           "src/python/libexec/vcfCmdlineSwapper.py"
                           "src/srcqc/run_cppcheck.py")
                         (("/usr/bin/env python") (string-append
                                                    (assoc-ref inputs "python")
                                                    "/bin/python")))
            #t))
        (add-after 'install 'fix-pyflow-shebang
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (substitute* (string-append (assoc-ref outputs "out")
                                        "/lib/python/pyflow/pyflow.py")
              (("#!/usr/bin/env python")
               (string-append "#!" (assoc-ref inputs "python")
                              "/bin/python")))
            #t)))))
    (inputs
     `(("cmake" ,cmake)
       ("boost" ,boost)
       ("pyflow" ,pyflow-2)
       ("python" ,python-2)
       ("cppcheck" ,cppcheck)
       ("doxygen" ,doxygen)
       ("graphviz" ,graphviz)
       ("htslib" ,htslib-1.9)
       ("samtools" ,samtools-1.9)
       ("zlib" ,zlib)
       ("bash" ,bash)))
    (home-page "https://github.com/Illumina/manta")
   (synopsis "Structural variant and indel caller for mapped sequencing data")
   (description "Manta calls structural variants (SVs) and indels from mapped
paired-end sequencing reads.  It is optimized for analysis of germline variation
in small sets of individuals and somatic variation in tumor/normal sample pairs.
Manta discovers, assembles and scores large-scale SVs, medium-sized indels and
large insertions within a single efficient workflow.")
   (license license:gpl3)))

;; This is a dependency for strelka.
(define-public codemin
  (package
   (name "codemin")
   (version "1.0.5")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/Illumina/strelka/raw/"
                  "5a993884687f2d92f794109e171d0bdeb95e504d"
                  "/redist/CodeMin-1.0.5.tar.bz2"))
            (sha256
             (base32 "1y8wsli1q626i80p3dmrc65p77ch164hj2sbxv497i9y89kvk35s"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f ; There are no tests.
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (delete 'build)
        (replace 'install
          (lambda* (#:key outputs #:allow-other-keys)
            (let ((include-dir (string-append
                                (assoc-ref outputs "out") "/include")))
              (mkdir-p include-dir)
              (copy-recursively "include" include-dir)))))))
   (home-page "https://github.com/Illumina/strelka/tree/master/redist")
   (synopsis "Set of lightweight minimization functions.")
   (description "The CodeMin minimization library provides a set of lightweight
minimization functions originally developed for the CodeAxe phylogenetic
analysis package.")
   ;; MIT license.
   (license license:expat)))

(define-public strelka-2.9.2
  (package
   (name "strelka")
   (version "2.9.2")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/Illumina/strelka/releases/download/v"
                  version "/strelka-" version ".release_src.tar.bz2"))
            (sha256
             (base32 "19bq2wzlxmnv8rx112y8z0sfvgsajnd0m945njmfy9p170qjqr27"))
            (patches
             (list (search-patch "strelka2-unbundle-dependencies.patch")))))
   (build-system cmake-build-system)
   (arguments
    `(#:tests? #f
      #:phases
      (modify-phases %standard-phases
        (add-after 'unpack 'unbundle-dependencies
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (substitute* "redist/CMakeLists.txt"
              ;; HTSlib
              (("superset\\(HTSLIB_DIR \"\\$\\{CMAKE_CURRENT_BINARY_DIR\\}/\\$\\{HTSLIB_PREFIX\\}\"\\)")
               (format #f "superset(HTSLIB_DIR \"~a/bin\")" (assoc-ref inputs "htslib")))
              (("superset\\(HTSLIB_LIBRARY \"\\$\\{HTSLIB_DIR\\}/libhts.a\"\\)")
               (format #f "superset(HTSLIB_LIBRARY \"~a/lib/libhts.so\")"
                       (assoc-ref inputs "htslib")))
              ;; SAMtools
              (("set\\(SAMTOOLS_DIR \"\\$\\{CMAKE_CURRENT_BINARY_DIR}/\\$\\{SAMTOOLS_PREFIX\\}\"\\)")
               (format #f "set(SAMTOOLS_DIR \"~a/bin\")"
                       (assoc-ref inputs "samtools")))
              (("set\\(SAMTOOLS_LIBRARY \"\\$\\{SAMTOOLS_DIR\\}/libbam.a\"\\)")
               (format #f "set(SAMTOOLS_LIBRARY \"~a/lib/libbam.a\")"
                       (assoc-ref inputs "samtools"))))))
        (add-after 'install 'install-shared-libraries
          (lambda* (#:key inputs outputs  #:allow-other-keys)
            (let ((libdir (string-append (assoc-ref outputs "out") "/lib")))
              (mkdir-p libdir)
              (map (lambda (file)
                     (copy-file file (string-append libdir "/" (basename file))))
                   (find-files "." "\\.so")))))
        (add-after 'install 'patch-python-bin
          (lambda* (#:key inputs outputs  #:allow-other-keys)
            (let ((patch-path (string-append (assoc-ref outputs "out") "/lib/python")))
              (substitute* (list (string-append patch-path "/makeRunScript.py")
                                 (string-append patch-path "/pyflow/pyflow.py"))
                (("/usr/bin/env python")
                 (string-append (assoc-ref inputs "python") "/bin/python")))))))))
   (inputs
    `(("boost" ,boost)
      ("perl" ,perl)
      ("bash" ,bash)
      ("zlib" ,zlib)
      ("samtools" ,samtools)
      ("rapidjson" ,rapidjson)
      ("codemin" ,codemin)
      ("curl" ,curl)
      ("xz" ,xz)
      ("openssl" ,openssl)
      ("samtools" ,samtools)
      ("zlib" ,zlib)
      ("python" ,python)))
   (native-inputs
    `(("bash" ,bash)
      ("python" ,python-2)
      ("doxygen" ,doxygen)
      ("graphviz" ,graphviz)))
   (propagated-inputs
    `(("vcftools" ,vcftools)
      ("htslib" ,htslib)))
   (native-search-paths (package-native-search-paths perl))
   (home-page "https://github.com/Illumina/strelka")
   (synopsis "Small variant caller")
   (description "Strelka2 is a fast and accurate small variant caller optimized
for analysis of germline variation in small cohorts and somatic variation in
tumor/normal sample pairs.  The germline caller employs an efficient tiered
haplotype model to improve accuracy and provide read-backed phasing, adaptively
selecting between assembly and a faster alignment-based haplotyping approach at
each variant locus.  The germline caller also analyzes input sequencing data
using a mixture-model indel error estimation method to improve robustness to
indel noise.  The somatic calling model improves on the original Strelka method
for liquid and late-stage tumor analysis by accounting for possible tumor cell
contamination in the normal sample.  A final empirical variant re-scoring step
using random forest models trained on various call quality features has been
added to both callers to further improve precision.")
   (license license:gpl3+)))

(define-public star-2.4.2a
  (package
    (name "star")
    (version "2.4.2a")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/alexdobin/STAR/archive/"
                                  "STAR_" version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "1c3rnm7r5l0kl3d04gl1g7938xqf1c2l0mla87rlplqg1hcns5mc"))
              (modules '((guix build utils)))
              (snippet
               '(begin
                  (substitute* "source/Makefile"
                    (("/bin/rm") "rm"))
                  ;; Remove pre-built binaries and bundled htslib sources.
                  (delete-file-recursively "bin/MacOSX_x86_64")
                  (delete-file-recursively "bin/Linux_x86_64")
                  (delete-file-recursively "source/htslib")
                  #t))))
    (build-system gnu-build-system)
    (arguments
     '(#:tests? #f ;no check target
       #:make-flags '("STAR")
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'enter-source-dir
           (lambda _ (chdir "source") #t))
         (add-after 'enter-source-dir 'do-not-use-bundled-htslib
           (lambda _
             (substitute* "Makefile"
               (("(Depend.list: \\$\\(SOURCES\\) parametersDefault\\.xxd) htslib"
                 _ prefix) prefix))
             (substitute* '("BAMfunctions.cpp"
                            "signalFromBAM.h"
                            ;"bam_cat.h"
                            "bam_cat.c"
                            "STAR.cpp"
                            "bamRemoveDuplicates.cpp")
               (("#include \"htslib/([^\"]+\\.h)\"" _ header)
                (string-append "#include <" header ">")))
             (substitute* "IncludeDefine.h"
               (("\"htslib/(htslib/[^\"]+.h)\"" _ header)
                (string-append "<" header ">")))
             #t))
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((bin (string-append (assoc-ref outputs "out") "/bin/")))
               (install-file "STAR" bin))
             #t))
         (delete 'configure))))
    (native-inputs
     `(("vim" ,vim))) ; for xxd
    (inputs
     `(("htslib" ,htslib)
       ("zlib" ,zlib)))
    (home-page "https://github.com/alexdobin/STAR")
    (synopsis "Universal RNA-seq aligner")
    (description
     "The Spliced Transcripts Alignment to a Reference (STAR) software is
based on a previously undescribed RNA-seq alignment algorithm that uses
sequential maximum mappable seed search in uncompressed suffix arrays followed
by seed clustering and stitching procedure.  In addition to unbiased de novo
detection of canonical junctions, STAR can discover non-canonical splices and
chimeric (fusion) transcripts, and is also capable of mapping full-length RNA
sequences.")
    ;; STAR is licensed under GPLv3 or later; htslib is MIT-licensed.
    (license license:gpl3+)))

;; Dependency of star-fusion
(define-public perl-set-intervaltree
  (package
   (name "perl-set-intervaltree")
   (version "0.10")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "mirror://cpan/authors/id/B/BE/BENBOOTH/Set-IntervalTree-"
           version ".tar.gz"))
     (sha256
      (base32 "1g1yam3fwl11wvy489yhhfzrfdlqaj1dh7pgks3myjq71p7rrgg3"))))
   (build-system perl-build-system)
   (home-page "http://search.cpan.org/dist/Set-IntervalTree")
   (synopsis "Perform range-based lookups on sets of ranges.")
   (description "")
   (license license:gpl1+)))

(define-public star-fusion
  (package
   (name "star-fusion")
   (version "1.0.0")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/STAR-Fusion/STAR-Fusion/releases/"
                  "download/v" version "/STAR-Fusion-v" version
                  ".FULL.tar.gz"))
            (sha256
             (base32 "19p5lwq2f95hgii7fdidz03845nkhf3pjfvp8v3midrsb0s6p7df"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f ; There is no test phase.
      #:phases
      (modify-phases %standard-phases
        (delete 'configure) ; There is nothing to configure.
        (delete 'build) ; There is nothing to compile/build.
        (add-before 'install 'patch-external-tools
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (let ((samtools (string-append (assoc-ref inputs "samtools") "/bin/samtools"))
                  (gunzip (string-append (assoc-ref inputs "gzip") "/bin/gunzip"))
                  (zcat (string-append (assoc-ref inputs "gzip") "/bin/zcat"))
                  (cat (string-append (assoc-ref inputs "coreutils") "/bin/cat"))
                  (wc (string-append (assoc-ref inputs "coreutils") "/bin/wc"))
                  (sort (string-append (assoc-ref inputs "coreutils") "/bin/sort"))
                  (mkdir (string-append (assoc-ref inputs "coreutils") "/bin/mkdir")))
              (substitute* "util/append_breakpoint_junction_info.pl"
                (("samtools") samtools))
              (substitute* "util/incorporate_FFPM_into_final_report.pl"
                (("gunzip") gunzip))
              (substitute* "util/STAR-Fusion.predict" (("gunzip") gunzip))
              (substitute* "util/incorporate_FFPM_into_final_report.pl" (("wc") wc))
              (substitute* "util/convert_to_FFPM.pl" (("wc") wc))
              (substitute* "util/incorporate_FFPM_into_final_report.pl"
                (("cat \\$fq_file") (string-append cat " $fq_file")))
              (substitute* "util/partition_FUSION_EVIDENCE_fastqs_by_fusion.pl"
                (("sort \\$tmp_paired") (string-append sort " $tmp_paired")))
              (substitute* "util/convert_to_FFPM.pl"
                (("\"cat \\$fq_filename") (string-append "\"" cat " $fq_filename")))
              (substitute* "util/convert_to_FFPM.pl"
                (("zcat \\$fq_filename") (string-append zcat " $fq_filename")))
              (substitute* "util/partition_FUSION_EVIDENCE_fastqs_by_fusion.pl"
                (("mkdir") mkdir))
              (substitute* "util/STAR-Fusion.filter" (("mkdir") mkdir))
              (substitute* "util/STAR-Fusion.predict" (("mkdir") mkdir)))))
        (replace 'install
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
              (mkdir-p bin)
              (install-file "STAR-Fusion" bin)
              (copy-recursively "PerlLib" (string-append bin "/PerlLib"))
              (copy-recursively "util" (string-append bin "/util"))
              (copy-recursively "FusionFilter"
                                (string-append bin "/FusionFilter"))))))))
   (inputs
    `(("perl" ,perl)
      ("samtools" ,samtools)
      ("coreutils" ,coreutils)
      ("gzip" ,gzip)))
   (propagated-inputs
    `(("perl-carp" ,perl-carp)
      ("perl-pathtools" ,perl-pathtools)
      ("perl-db-file" ,perl-db-file)
      ("perl-uri" ,perl-uri)
      ("perl-set-intervaltree" ,perl-set-intervaltree)))
   (home-page "https://github.com/STAR-Fusion/STAR-Fusion/")
   (synopsis "Fusion detection based on STAR")
   (description "This package provides a component of the Trinity Cancer
Transcriptome Analysis Toolkit (CTAT).  It uses the STAR aligner to identify
candidate fusion transcripts supported by Illumina reads.  It further
processes the output generated by the STAR aligner to map junction reads and
spanning reads to a reference annotation set.")
   (license license:bsd-3)))

(define-public python-nanosv
  (package
   (name "python-nanosv")
   (version "1.2.4")
   (source (origin
            (method url-fetch)
            (uri (pypi-uri "NanoSV" version))
            (sha256
             (base32
              "1wl2daj0bwrl8fx5xi8j8hfs3mp3vg3qycy66538n032v1qkc6xg"))))
   (build-system python-build-system)
   (propagated-inputs
    `(("python-configparser" ,python-configparser)
      ("python-pysam" ,python-pysam)
      ("python-pyvcf" ,python-pyvcf)))
   (home-page "https://github.com/mroosmalen/nanosv")
   (synopsis "Structural variation detection tool for Oxford Nanopore data.")
   (description "Structural variation detection tool for Oxford Nanopore data.")
   (license license:expat)))

(define-public primer3-1.1.4
  (package
    (name "primer3")
    (version "1.1.4")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/primer3-org/primer3/archive/v"
                    version ".tar.gz"))
              (sha256
               (base32
                "1nkxyw811xbb7gid0dbcw4k7yg3q1mw6hv96076xx0j10ishmh1w"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-before 'build 'change-directory
           (lambda _ (chdir "src")))
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin")))
               (mkdir-p bin)
               (for-each (lambda (file) (install-file file bin))
                         '("primer3_core" "oligotm" "ntdpal"))))))))
    (inputs
     `(("perl" ,perl)))
    (home-page "https://github.com/primer3-org/primer3")
    (synopsis "Tool to design PCR primers")
    (description "Design PCR primers from DNA sequence.  From mispriming
libraries to sequence quality data to the generation of internal oligos,
primer3 does it.")
    (license license:gpl2)))

(define-public gnomad-sv-sites-2.1
  (package
   (name "gnomad-sv-sites")
   (version "2.1")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://storage.googleapis.com/gnomad-public/"
                  "papers/2019-sv/gnomad_v" version "_sv.sites.vcf.gz"))
            (sha256
             (base32
              "18gxfnar8n5r06mj0ykyq4fkw3q3qqbrfnprgi18db0xzf6lh94k"))))
   (build-system trivial-build-system)
   (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let ((gzip     (string-append (assoc-ref %build-inputs "gzip") "/bin/gzip"))
               (sv-sites (assoc-ref %build-inputs "source"))
               (out      (string-append %output "/share/gnomad")))
           (mkdir-p out)
           (with-directory-excursion out
             (zero? (system
                     (string-append
                      gzip " -d " sv-sites
                      " -c > gnomad_v2.1_sv.sites.vcf"))))))))
   (inputs `(("gzip" ,gzip)))
   (home-page "https://gnomad.broadinstitute.org")
   (synopsis "gnomAD structural variant sites")
   (description "This package provides in uncompressed version of the gnomAD
 structural variant sites.")
   (license license:cc0)))

(define-public sharc
  (package
   (name "sharc")
   (version "1.0-slurm")
   (source (origin
            (method url-fetch)
            (uri "https://github.com/UMCUGenetics/SHARC/archive/1.0.tar.gz")
            (file-name (string-append name "-" version ".tar.gz"))
            (sha256
             (base32
              "05121h8nrrsd4j9xk0dg92p1js6m849x8p2vj5mss1fzf50cdyv7"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f ; There are no tests
      #:phases
      (modify-phases %standard-phases
                     (delete 'configure)
                     (delete 'build)
                     (add-after 'unpack 'patch-external-programs
                      (lambda* (#:key inputs outputs #:allow-other-keys)
                        (let* ((out        (assoc-ref outputs "out"))
                               (share      (string-append out "/share/sharc"))
                               (venvdir    (string-append share "/venv/bin"))
                               (scriptsdir (string-append share "/scripts"))
                               (primerdir  (string-append scriptsdir "/primers"))
                               (stepsdir   (string-append share "/steps"))
                               (filesdir   (string-append share "/files")))
                          (substitute* "sharc.sh"
                           (("/hpc/cog_bioinf/cuppen/personal_data/jvalleinclan/tools_kloosterman/minimap2_v2.12/minimap2")
                            (string-append (assoc-ref inputs "minimap2") "/bin/minimap2"))
                           (("SHARCDIR=\\$\\(dirname \\$\\{BASH_SOURCE\\[0\\]\\}\\)")
                            (string-append "SHARCDIR='" out "'"))
                           (("VENV=\\$SHARCDIR/venv/bin/activate")
                            (string-append "VENV=" venvdir "/activate"))
                           (("STEPSDIR=\\$SHARCDIR/steps")
                            (string-append "STEPSDIR=" stepsdir))
                           (("SCRIPTSDIR=\\$SHARCDIR/scripts")
                            (string-append "SCRIPTSDIR=" scriptsdir))
                           (("FILESDIR=\\$SHARCDIR/files")
                            (string-append "FILESDIR=" filesdir))
                           (("python \\$PON_SCRIPT") "PY2 $PON_SCRIPT")
                           (("\\$PRIMER_DESIGN_DIR/primer3/src/primer3_core")
                            (string-append (assoc-ref inputs "primer3") "/bin/primer3_core"))
                           (("\\$\\{FILESDIR\\}/gnomad_v2.1_sv.sites.vcf")
                            (string-append (assoc-ref inputs "gnomad-sv-sites")
                                           "/share/gnomad/gnomad_v2.1_sv.sites.vcf")))

                          (substitute* '("steps/vcf_fasta.sh"
                                         "steps/vcf_primer_filter.sh"
                                         "steps/somatic_ranking.sh"
                                         "steps/top20_report.sh"
                                         "steps/somatic_feature_selection.sh"
                                         "steps/randomForest.sh"
                                         "steps/randomForest.sh"
                                         "steps/randomForest.sh"
                                         "steps/bed_annotation.sh")
                           (("/hpc/cog_bioinf/cuppen/project_data/Jose_SHARC/sharc/scripts")
                            scriptsdir))

                          (substitute* '("steps/vcf_fasta.sh"
                                         "steps/nanosv.sh"
                                         "steps/vcf_primer_filter.sh"
                                         "steps/somatic_ranking.sh"
                                         "steps/top20_report.sh"
                                         "steps/somatic_feature_selection.sh"
                                         "steps/randomForest.sh"
                                         "steps/bed_annotation.sh")
                           (("VENV='/hpc/cog_bioinf/cuppen/project_data/Jose_SHARC/sharc/venv/bin/activate'")
                            (string-append venvdir "/activate")))

                          (substitute* '("steps/calculate_coverage.sh"
                                         "steps/nanosv.sh"
                                         "steps/somatic_feature_selection.sh")
                           (("/hpc/cog_bioinf/cuppen/project_data/Jose_SHARC/sharc/files")
                            filesdir))

                           (substitute* "steps/minimap2.sh"
                            (("/hpc/cog_bioinf/cuppen/personal_data/jvalleinclan/tools_kloosterman/minimap2_v2.12/minimap2")
                             (string-append (assoc-ref inputs "minimap2") "/bin/minimap2")))

                           (substitute* '("steps/bed_annotation.sh"
                                          "steps/calculate_coverage.sh"
                                          "steps/create_bed_annotation_jobs.sh"
                                          "steps/minimap2.sh"
                                          "steps/nanosv.sh"
                                          "steps/primer_design.sh"
                                          "steps/primer_ranking.sh"
                                          "steps/randomForest.sh"
                                          "steps/sharc_filter.sh"
                                          "steps/somatic_feature_selection.sh"
                                          "steps/somatic_ranking.sh"
                                          "steps/top20_report.sh"
                                          "steps/vcf_fasta.sh"
                                          "steps/vcf_filter.sh"
                                          "steps/vcf_primer_filter.sh"
                                          "steps/vcf_split.sh"
                                          "sharc.sh")
                            (("/hpc/local/CentOS7/cog_bioinf/sambamba_v0.6.5/sambamba")
                             (string-append (assoc-ref inputs "sambamba") "/bin/sambamba"))
                            (("#!/bin/bash")
                             (format #f "#!~a/bin/bash~%~%~{export ~:a~%~}"
                                     (assoc-ref inputs "bash")
                                     `(,(let ((python-inputs
                                               (delete #f
                                                (map (lambda (pair)
                                                       (if (string-prefix? "python-" (car pair))
                                                           (format #f "~a/lib/python~a/site-packages"
                                                                   (cdr pair) "3.8")
                                                           #f))
                                                     inputs))))
                                          (format #f "PYTHONPATH=\"~a~{:~a~}\""
                                                  (car python-inputs)
                                                  (cdr python-inputs)))
                                       ,(format #f "R_LIBS_SITE=~s" (getenv "R_LIBS_SITE")))))
                            (("Rscript")
                             (string-append (assoc-ref inputs "r") "/bin/Rscript"))
                            (("qsub")
                             (string-append (assoc-ref inputs "grid-engine-core") "/bin/qsub -V"))
                            (("python ")
                             (string-append (assoc-ref inputs "python") "/bin/python3 "))
                            (("PY2")
                             (string-append (assoc-ref inputs "python-2") "/bin/python"))
                            (("NanoSV ")
                             (string-append (assoc-ref inputs "python-nanosv") "/bin/NanoSV "))
                            (("module load R") ""))

                           (substitute* "steps/create_bed_annotation_jobs.sh"
                            (("bash \\$STEPSDIR")
                             (string-append (assoc-ref inputs "bash") "/bin/bash $STEPSDIR")))

                           (substitute* "scripts/run_randomForest.R"
                            (("/hpc/cog_bioinf/kloosterman/common_scripts/sharc/scripts")
                             scriptsdir)
                            (("randomforest_vl_v3_3overlap_p96_r99.5_pc0.39.Rdata")
                             "randomforest_v3_3overlap_p96_r99.5_pc0.39.Rdata"))

                           ;; Use Guix's Python.
                           (substitute* '("scripts/add_predict_annotation.py"
                                          "scripts/create_features_table.py"
                                          "scripts/get_closest_feature.py"
                                          "scripts/primer_ranking.py"
                                          "scripts/somatic_feature_selection.py"
                                          "scripts/somatic_ranking.py"
                                          "scripts/top20_report.py"
                                          "scripts/vcf_primer_filter.py"
                                          "scripts/vcf_to_fasta.py")
                            (("/usr/bin/python") (string-append
                                                  (assoc-ref inputs "python")
                                                  "/bin/python3")))

                           (substitute* '("scripts/primers/primerBATCH1"
                                          "scripts/primers/amplicons3.pl"
                                          "scripts/primers/format_primers1.pl")
                            (("/usr/bin/perl")
                             (string-append (assoc-ref inputs "perl") "/bin/perl")))

                           (substitute* "scripts/annotate_sv_vcf_file.py"
                            (("/usr/bin/python")
                             (string-append
                              (assoc-ref inputs "python-2")
                              "/bin/python")))

                           (substitute* "scripts/primers/primerBATCH1"
                            (("/hpc/cuppen/projects/TP0001_General/COLO/analysis/jvalleinclan/bin/tools_kloosterman/primer3/primers")
                             primerdir))

                           (substitute* "scripts/primers/amplicons3.pl"
                            (("eprimer3 ")
                             (string-append (assoc-ref inputs "emboss")
                                            "/bin/eprimer3 ")))

                           #t)))

                     (replace 'install
                      (lambda* (#:key inputs outputs #:allow-other-keys)
                        (let* ((out        (assoc-ref outputs "out"))
                               (bin        (string-append out "/bin"))
                               (share      (string-append out "/share/sharc"))
                               (venvdir    (string-append share "/venv/bin"))
                               (scriptsdir (string-append share "/scripts"))
                               (stepsdir   (string-append share "/steps"))
                               (filesdir   (string-append share "/files")))
                          (mkdir-p bin)
                          (mkdir-p venvdir)
                          (mkdir-p scriptsdir)
                          (mkdir-p stepsdir)
                          (mkdir-p filesdir)
                          (copy-recursively "scripts" scriptsdir)
                          (copy-recursively "steps" stepsdir)
                          (copy-recursively "files" filesdir)

                          ;; Create an empty virtual environment
                          (call-with-output-file (string-append venvdir "/activate")
                            (lambda (port)
                              (format port "export DEACTIVATE_PATH=$PATH~%")
                              (format port "export PATH=$PATH:~s~%" venvdir)
                              (format port "printf \"Environment activated.\\n\";~%")))
                          (let ((deactivate (string-append venvdir "/deactivate")))
                            (call-with-output-file deactivate
                              (lambda (port)
                                (format port "#!~a/bin/bash~%" (assoc-ref inputs "bash"))
                                (format port "export PATH=${DEACTIVATE_PATH}~%")
                                (format port "printf \"Environment deactivated.\\n\";~%exit 0;~%")))
                            (chmod deactivate #o555))
                          (install-file "sharc.sh" bin)
                          (with-directory-excursion bin
                                                    (symlink "sharc.sh" "sharc"))))))))
   (inputs
    `(("awk" ,gawk)
      ("bash" ,bash)
      ("coreutils" ,coreutils)
      ("emboss" ,emboss)
      ("grep" ,grep)
      ("grid-engine-core" ,qsub-slurm)
      ("minimap2" ,minimap2)
      ("primer3" ,primer3-1.1.4)
      ("perl" ,perl)
      ("python" ,python)
      ("python-aniso8601" ,python-aniso8601)
      ("python-certifi" ,python-certifi)
      ("python-chardet" ,python-chardet)
      ("python-configparser" ,python-configparser)
      ("python-flask" ,python-flask)
      ("python-flask-restful" ,python-flask-restful)
      ("python-idna" ,python-idna)
      ("python-itsdangerous" ,python-itsdangerous)
      ("python-jinja2" ,python-jinja2)
      ("python-markupsafe" ,python-markupsafe)
      ("python-nanosv" ,python-nanosv)
      ("python-pymongo" ,python-pymongo)
      ("python-pysam" ,python-pysam)
      ("python-pytz" ,python-pytz)
      ("python-pyvcf" ,python-pyvcf)
      ("python-requests" ,python-requests)
      ("python-six" ,python-six)
      ("python-urllib3" ,python-urllib3)
      ("python-werkzeug" ,python-werkzeug)
      ("python-2" ,python-2)
      ("r" ,r-minimal)
      ("r-ggplot2" ,r-ggplot2)
      ("r-randomforest", r-randomforest)
      ("r-rocr" ,r-rocr)
      ("sambamba" ,sambamba)
      ("sed" ,sed)
      ("gnomad-sv-sites" ,gnomad-sv-sites-2.1)))
   (native-search-paths
    (append (package-native-search-paths bash)
            (package-native-search-paths python)
            (package-native-search-paths perl)
            (package-native-search-paths r)))
   (search-paths native-search-paths)
   (home-page "https://github.com/UMCUGenetics/SHARC")
   (synopsis "Somatic SV pipeline for tumor-only Nanopore sequencing data")
   (description "SHARC is a pipeline for somatic SV calling and filtering
from tumor-only Nanopore sequencing data. It performs mapping, SV calling,
SV filtering, random forest classification, blacklist filtering and SV
prioritization, followed by automated primer design for PCR amplicons of
80-120 bp that are useful to track cancer ctDNA molecules in liquid
biopsies.")
   (license license:gpl3)))

(define-public sharc-local
  (package (inherit sharc)
     (name "sharc")
     (version "1.0-local")
     (inputs
      `(("awk" ,gawk)
        ("bash" ,bash)
        ("coreutils" ,coreutils)
        ("emboss" ,emboss)
        ("grep" ,grep)
        ("grid-engine-core" ,qsub-local)
        ("minimap2" ,minimap2)
        ("primer3" ,primer3-1.1.4)
        ("perl" ,perl)
        ("python" ,python)
        ("python-aniso8601" ,python-aniso8601)
        ("python-certifi" ,python-certifi)
        ("python-chardet" ,python-chardet)
        ("python-configparser" ,python-configparser)
        ("python-flask" ,python-flask)
        ("python-flask-restful" ,python-flask-restful)
        ("python-idna" ,python-idna)
        ("python-itsdangerous" ,python-itsdangerous)
        ("python-jinja2" ,python-jinja2)
        ("python-markupsafe" ,python-markupsafe)
        ("python-nanosv" ,python-nanosv)
        ("python-pymongo" ,python-pymongo)
        ("python-pysam" ,python-pysam)
        ("python-pytz" ,python-pytz)
        ("python-pyvcf" ,python-pyvcf)
        ("python-requests" ,python-requests)
        ("python-six" ,python-six)
        ("python-urllib3" ,python-urllib3)
        ("python-werkzeug" ,python-werkzeug)
        ("python-2" ,python-2)
        ("r" ,r-minimal)
        ("r-ggplot2" ,r-ggplot2)
        ("r-randomforest", r-randomforest)
        ("r-rocr" ,r-rocr)
        ("sambamba" ,sambamba)
        ("sed" ,sed)
        ("gnomad-sv-sites" ,gnomad-sv-sites-2.1)))))

(define-public sharc-sge
  (package (inherit sharc)
     (name "sharc")
     (version "1.0-sge")
     (inputs
      `(("awk" ,gawk)
        ("bash" ,bash)
        ("coreutils" ,coreutils)
        ("emboss" ,emboss)
        ("grep" ,grep)
        ("grid-engine-core" ,grid-engine-core)
        ("minimap2" ,minimap2)
        ("primer3" ,primer3-1.1.4)
        ("perl" ,perl)
        ("python" ,python)
        ("python-aniso8601" ,python-aniso8601)
        ("python-certifi" ,python-certifi)
        ("python-chardet" ,python-chardet)
        ("python-configparser" ,python-configparser)
        ("python-flask" ,python-flask)
        ("python-flask-restful" ,python-flask-restful)
        ("python-idna" ,python-idna)
        ("python-itsdangerous" ,python-itsdangerous)
        ("python-jinja2" ,python-jinja2)
        ("python-markupsafe" ,python-markupsafe)
        ("python-nanosv" ,python-nanosv)
        ("python-pymongo" ,python-pymongo)
        ("python-pysam" ,python-pysam)
        ("python-pytz" ,python-pytz)
        ("python-pyvcf" ,python-pyvcf)
        ("python-requests" ,python-requests)
        ("python-six" ,python-six)
        ("python-urllib3" ,python-urllib3)
        ("python-werkzeug" ,python-werkzeug)
        ("python-2" ,python-2)
        ("r" ,r-minimal)
        ("r-ggplot2" ,r-ggplot2)
        ("r-randomforest", r-randomforest)
        ("r-rocr" ,r-rocr)
        ("sambamba" ,sambamba)
        ("sed" ,sed)
        ("gnomad-sv-sites" ,gnomad-sv-sites-2.1)))))

(define-public allelecount
  (package
    (name "allelecount")
    (version "3.3.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/cancerit/alleleCount/archive/v"
                    version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0yza03nma4y5f34x61pdi902fkv9hzkfbpry9qs3nphjf6q5wcwj"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-before 'build 'move-to-subdirectory
           (lambda _
             (chdir "perl")))
         (replace 'build
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (system* "perl" "Makefile.PL"
                      (string-append "PREFIX=" (assoc-ref outputs "out")))
             (system* "make")
             ;; Build the C alleleCounter program.
             (chdir "../c")
             (mkdir-p "bin")
             (substitute* "src/bam_access.c"
               (("\\#include <cram\\/cram.h>") "#include <htslib/cram.h>"))
             (system* "make")
             ;; Don't interfere with the "make install" command for the Perl
             ;; version.
             (chdir "../perl")))
         (add-after 'install 'install-allelecounter
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (string-append (assoc-ref outputs "out") "/bin")))
               (install-file "../c/bin/alleleCounter" out)))))))
    (propagated-inputs
     `(("perl-const-fast" ,perl-const-fast)
       ("perl-sub-exporter-progressive" ,perl-sub-exporter-progressive)
       ("perl-bio-db-hts" ,perl-bio-db-hts)
       ("bioperl-minimal" ,bioperl-minimal)))
    (inputs
     `(("zlib" ,zlib)
       ("htslib" ,htslib)
       ("perl-pod-coverage" ,perl-pod-coverage)
       ("perl-file-which" ,perl-file-which)
       ("perl-test-fatal" ,perl-test-fatal)
       ("perl-try-tiny" ,perl-try-tiny)
       ("samtools" ,samtools)))
    (native-inputs
     `(("perl-module-build" ,perl-module-build)
       ("perl" ,perl)))
    (home-page "https://github.com/cancerit/alleleCount")
    (synopsis "Support code for NGS copy number algorithms")
    (description "This package primarily exists to prevent code duplication
between some other projects, specifically AscatNGS and Battenburg.")
    (license license:agpl3+)))

(define-public libmaus
  (package
   (name "libmaus")
   (version "0.0.196")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/gt1/libmaus/archive/"
                  version "-release-20150326095654.tar.gz"))
            (sha256
             (base32
              "0g92bl37ci8pzkgi2xnn2bck7y655jwcb1bm3mg42mj5lf5x2i5b"))))
   (build-system gnu-build-system)
   (native-inputs
    `(("pkg-config" ,pkg-config)))
   (inputs
    `(("zlib" ,zlib)))
   (home-page "https://github.com/gt1/libmaus")
   (synopsis "Collection of bioinformatics data structures and algorithms")
   (description "This package contains a collection of bioinformatics data
structures and algorithms.  It provides I/O classes, bitio classes, text
indexing classes and BAM sequence alignment functionality.")
   (license license:gpl3+)))

(define-public biobambam
  (package
   (name "biobambam")
   (version "0.0.191")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/gt1/biobambam/archive/" version
                  "-release-20150401083643.tar.gz"))
            (file-name (string-append name "-" version ".tar.gz"))
            (sha256
             (base32 "065fcwdh5sb6dg3mf5qk9w2818jxm27pvbv976qc00y7np2y2nqz"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f))
   (inputs
    `(("libmaus" ,libmaus)
      ("zlib" ,zlib)))
   (native-inputs
    `(("pkg-config" ,pkg-config)))
   (home-page "https://github.com/gt1/biobambam")
   (synopsis "Collection of tools to work with BAM files")
   (description "This package contains the following programs: bamcollate2,
bammarkduplicates, bammaskflags, bamrecompress, bamsort, bamtofastq.")
   (license license:gpl3+)))

(define-public pcap-core
  (package
   (name "pcap-core")
   (version "3.5.0")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/ICGC-TCGA-PanCancer/PCAP-core/archive/v"
                  version ".tar.gz"))
            (file-name (string-append name "-" version ".tar.gz"))
            (sha256
             (base32 "06im5lf00jyghwmqjzb3dpglgjx7pi5ysda75fw8ygmj1fi5q8kj"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f
      #:phases
      (modify-phases %standard-phases
        (replace 'configure
          (lambda* (#:key outputs #:allow-other-keys)
            (system* "perl" "Makefile.PL"
                     (string-append "PREFIX=" (assoc-ref outputs "out"))))))))
   (propagated-inputs
    `(("bwa" ,bwa)
      ("samtools" ,samtools)
      ("biobambam" ,biobambam)))
   (native-inputs
    `(("perl-module-install" ,perl-module-install)
      ("perl-module-build" ,perl-module-build)
      ("perl-file-sharedir-install" ,perl-file-sharedir-install)
      ("perl" ,perl)
      ("perltidy" ,perltidy)))
   (home-page "https://github.com/ICGC-TCGA-PanCancer/PCAP-core")
   (synopsis "NGS reference implementations and helper code for the ICGC/TCGA
Pan-Cancer Analysis Project")
   (description "")
   (license license:gpl2+)))

(define-public perl-bio-pipeline-comparison
  (package
    (name "perl-bio-pipeline-comparison")
    (version "1.123050")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://cpan/authors/id/A/AJ/AJPAGE/"
                           "Bio-Pipeline-Comparison-" version ".tar.gz"))
       (sha256
        (base32
         "081kn3zyi7zcwkaxrk5w52nkx7jrp0pwjcr8sai25l45711xli49"))))
    (build-system perl-build-system)
    ;; Only one test fails.
    (arguments `(#:tests? #f))
    (propagated-inputs
     `(("htslib" ,htslib)
       ("which" ,which)))
    (native-inputs
     `(("perl-env-path" ,perl-env-path)
       ("perl-test-most" ,perl-test-most)))
    (inputs
     `(("bioperl-minimal" ,bioperl-minimal)
       ("perl-exception-class" ,perl-exception-class)
       ("perl-file-which" ,perl-file-which)
       ("perl-moose" ,perl-moose)
       ("perl-try-tiny" ,perl-try-tiny)))
    (home-page "http://search.cpan.org/dist/Bio-Pipeline-Comparison")
    (synopsis "Comparative assesment of variant calling (CAVar)")
    (description "")
    (license #f)))

(define-public perl-cgpvcf
  (package
   (name "perl-cgpvcf")
   (version "2.0.4")
   (source (origin
            (method url-fetch)
            (uri (string-append "https://github.com/cancerit/cgpVcf/archive/v"
                                version ".tar.gz"))
            (file-name (string-append name "-" version ".tar.gz"))
            (sha256
             (base32 "009vpq2l1pxqfsvckapzxav5xr6kcjvg3krrfdx40qammcr4q1ak"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f
      #:phases
      (modify-phases %standard-phases
        (replace 'configure
          (lambda* (#:key outputs #:allow-other-keys)
            (system* "perl" "Makefile.PL"
                     (string-append "PREFIX=" (assoc-ref outputs "out"))))))))
   (propagated-inputs
    `(("perl-bio-pipeline-comparison" ,perl-bio-pipeline-comparison)
      ("perl-const-fast" ,perl-const-fast)
      ("perl-data-uuid" ,perl-data-uuid)
      ("perl-datetime" ,perl-datetime)))
   (native-inputs
    `(("perl-module-install" ,perl-module-install)
      ("perl-module-build" ,perl-module-build)
      ("perl" ,perl)
      ("perltidy" ,perltidy)))
   (home-page "https://cancerit.github.io/cgpVcf/")
   (synopsis "Set of common Perl utilities for generating VCF headers")
   (description "This package contains a set of common Perl utilities for
generating consistent Vcf headers.  It primarily exists to prevent code
duplication between some other projects.")
   (license license:agpl3+)))

(define-public caveman
  (package
   (name "caveman")
   (version "1.9.4")
   (source (origin
            (method url-fetch)
            (uri (string-append "https://github.com/cancerit/CaVEMan/archive/"
                                version ".tar.gz"))
            (sha256
             (base32 "19h631avgknidbchk6997ckgd60072nlbg9hv2zxn6vvq3fpsyb8"))))
   (build-system gnu-build-system)
   (arguments
    `(#:make-flags (list (string-append
                          "HTSLOC=" (assoc-ref %build-inputs "htslib")))
      #:tests? #f ; Tests require a network connection.
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (add-before 'build 'patch-out-tests
          (lambda _
            (substitute* "Makefile"
             (("copyscript test") "copyscript"))))
        (replace 'install
          (lambda* (#:key outputs #:allow-other-keys)
            (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
              (install-file "bin/caveman" bin)
              (install-file "bin/generateCavemanUMNormVCF" bin)
              (install-file "bin/mergeCavemanResults" bin)))))))
   (inputs
    `(("htslib" ,htslib)
      ("zlib" ,zlib)
      ("perl" ,perl)))
   (home-page "http://cancerit.github.io/CaVEMan/")
   (synopsis "Implementation of an SNV expectation maximisation algorithm for
calling single base substitutions in paired data")
   (description "A C implementation of the CaVEMan program.  Uses an expectation
maximisation approach to calling single base substitutions in paired data.  It
is designed for use with a compute cluster.  Most steps in the program make use
of an index parameter.  The split step is designed to divide the genome into
chunks of adjustable size to optimise for runtime/memory usage requirements.")
   (license license:agpl3+)))

(define-public perl-forks
  (package
  (name "perl-forks")
  (version "0.36")
  (source
    (origin
      (method url-fetch)
      (uri (string-append
             "mirror://cpan/authors/id/R/RY/RYBSKEJ/forks-"
             version
             ".tar.gz"))
      (sha256
        (base32
          "14srnq51n98aizdlg6lhzpzdqyjvxf5nfm431qiylvsc9zj29gk1"))))
  (build-system perl-build-system)
  (propagated-inputs
    `(("perl-acme-damn" ,perl-acme-damn)
      ("perl-devel-symdump" ,perl-devel-symdump)
      ("perl-list-moreutils" ,perl-list-moreutils)
      ("perl-sys-sigaction" ,perl-sys-sigaction)))
  (home-page "http://search.cpan.org/dist/forks")
  (synopsis "forks - emulate threads with fork")
  (description "")
  (license (package-license perl))))

(define-public perl-acme-damn
  (package
   (name "perl-acme-damn")
   (version "0.08")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "https://cpan.metacpan.org/authors/id/I/IB/IBB/Acme-Damn-"
           version
           ".tar.gz"))
     (sha256
      (base32
       "03kykdsz3fk5ppb9g92pvnif67zlk501finrwi1csbcizw1js39i"))))
   (build-system perl-build-system)
   (inputs
    `(("perl-test-exception" ,perl-test-exception)))
   (home-page "http://search.cpan.org/dist/Acme-Damn")
   (synopsis "'Unbless' Perl objects.")
   (description "")
   (license license:perl-license)))

(define-public perl-sys-sigaction
  (package
   (name "perl-sys-sigaction")
   (version "0.23")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "mirror://cpan/authors/id/L/LB/LBAXTER/Sys-SigAction-"
           version
           ".tar.gz"))
     (sha256
      (base32
       "0lykjlq5dsf7z927lpllzixd953izi3w7bg2pgy32h2k8n9nrvy4"))))
   (build-system perl-build-system)
   (home-page
    "http://search.cpan.org/dist/Sys-SigAction")
   (synopsis
    "Perl extension for Consistent Signal Handling")
   (description "")
   (license (package-license perl))))

(define-public cgp-cavemanpostprocessing
  (package
    (name "cgp-cavemanpostprocessing")
    (version "1.8.9")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/cancerit/cgpCaVEManPostProcessing/"
                    "archive/" version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "01h2vd8vz8vd4sdgjh13sy2kb98w2lgrqamqpw65ivvhb96yg3qf"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'install)
         ;; The Perl in Guix does not support threads.
         ;; The forks module is a drop-in replacement for it, so it
         ;; is easier to use that instead of recompiling Perl.
         (add-after 'unpack 'enable-threads
           (lambda _
             (substitute* "bin/cgpFlagCaVEMan.pl"
               (("use strict;") "use forks;\nuse strict;"))))
         (replace 'build
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let ((bin-dir (string-append (assoc-ref outputs "out") "/bin"))
                   (lib-dir (string-append (assoc-ref outputs "out")
                            "/lib/perl5/site_perl/5.28.0"))
                   (config-dir (string-append (assoc-ref outputs "out") "/config")))
               (mkdir-p bin-dir)
               (mkdir-p lib-dir)
               (mkdir-p config-dir)
               (install-file "bin/cgpFlagCaVEMan.pl" bin-dir)
               (copy-recursively "lib" lib-dir)
               (copy-recursively "config" config-dir)
               #t))))))
    (propagated-inputs
     `(("perl-file-path" ,perl-file-path)
       ("perl-file-which", perl-file-which)
       ("perl-const-fast", perl-const-fast)
       ("perl-capture-tiny", perl-capture-tiny)
       ("perl-ipc-system-simple", perl-ipc-system-simple)
       ("perl-try-tiny", perl-try-tiny)
       ("perl-carp", perl-carp)
       ("perl-forks", perl-forks)
       ("perl-attribute-util", perl-attribute-util)
       ("perl-config-inifiles", perl-config-inifiles)
       ("perl-set-intervaltree", perl-set-intervaltree)
       ("perl-libwww", perl-libwww)
       ("pcap-core" ,pcap-core)
       ("perl-cgpvcf", perl-cgpvcf)
       ("perl-bio-db-hts", perl-bio-db-hts)
       ("bioperl-minimal", bioperl-minimal)
       ("perl" ,perl)))
    (home-page "https://github.com/cancerit/cgpCaVEManPostProcessing")
    (synopsis "Flagging add-on to CaVEMan")
    (description "This package is used to apply filtering on raw VCF calls
generated using CaVEMan.")
    (license license:agpl3+)))

(define-public perl-term-ui
  (package
    (name "perl-term-ui")
    (version "0.46")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/Term-UI-"
             version ".tar.gz"))
       (sha256
        (base32
         "19p92za5cx1v7g57pg993amprcvm1az3pp7y9g5b1aplsy06r54i"))))
    (build-system perl-build-system)
    (arguments `(#:tests? #f))
    (propagated-inputs
     `(("perl-log-message-simple" ,perl-log-message-simple)))
    (home-page "http://search.cpan.org/dist/Term-UI")
    (synopsis "User interfaces via Term::ReadLine made easy")
    (description "")
    (license (package-license perl))))

(define-public perl-devel-cover
  (package
    (name "perl-devel-cover")
    (version "1.29")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "mirror://cpan/authors/id/P/PJ/PJCJ/Devel-Cover-"
             version ".tar.gz"))
       (sha256
        (base32
         "0afkabxbbbwbnfh6b957cwxx1vcz00r4q49jbhcip3w6ib4pv60n"))))
    (build-system perl-build-system)
    (arguments
     `(#:tests? #f))
    (native-inputs
     `(("perl-test-differences" ,perl-test-differences)))
    (inputs
     `(("perl-browser-open" ,perl-browser-open)
       ("perl-capture-tiny" ,perl-capture-tiny)
       ("perl-class-xsaccessor" ,perl-class-xsaccessor)
       ("perl-moo" ,perl-moo)
       ("perl-namespace-clean" ,perl-namespace-clean)
       ("perl-parallel-iterator" ,perl-parallel-iterator)
       ("perltidy" ,perltidy)
       ("perl-pod-coverage" ,perl-pod-coverage)
       ("perl-ppi-html" ,perl-ppi-html)
       ("perl-template-toolkit" ,perl-template-toolkit)
       ("perl-test-differences" ,perl-test-differences)))
    (home-page
     "http://search.cpan.org/dist/Devel-Cover")
    (synopsis "Code coverage metrics for Perl")
    (description "")
    (license (package-license perl))))

(define-public perl-parallel-iterator
  (package
    (name "perl-parallel-iterator")
    (version "1.00")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "mirror://cpan/authors/id/A/AN/ANDYA/Parallel-Iterator-"
             version ".tar.gz"))
       (sha256
        (base32
         "1x252cqzcyxkmf8p5dw34ais47ci1ldv2ds02m7a2ijpryam0jg8"))))
    (build-system perl-build-system)
    (native-inputs
     `(("perl-module-install" ,perl-module-install)
       ("perl-module-build" ,perl-module-build)
       ("perl-file-sharedir-install" ,perl-file-sharedir-install)))
    (home-page
     "http://search.cpan.org/dist/Parallel-Iterator")
    (synopsis "Simple parallel execution")
    (description "")
    (license (package-license perl))))

(define-public perl-ppi
  (package
    (name "perl-ppi")
    (version "1.236")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "mirror://cpan/authors/id/M/MI/MITHALDU/PPI-"
             version
             ".tar.gz"))
       (sha256
        (base32
         "1v4a622h19d2d6m070jcxn47siqma9g9ly4fcrnrlz8bkhs4nry6"))))
    (build-system perl-build-system)
    (arguments
     `(#:tests? #f))
    (native-inputs
     `(("perl-class-inspector" ,perl-class-inspector)
       ("perl-file-remove" ,perl-file-remove)
       ("perl-test-nowarnings" ,perl-test-nowarnings)
       ("perl-test-object" ,perl-test-object)
       ("perl-test-subcalls" ,perl-test-subcalls)))
    (inputs
     `(("perl-clone" ,perl-clone)
       ("perl-io-string" ,perl-io-string)
       ("perl-list-moreutils" ,perl-list-moreutils)
       ("perl-params-util" ,perl-params-util)
       ("perl-task-weaken" ,perl-task-weaken)))
    (home-page "http://search.cpan.org/dist/PPI")
    (synopsis "Parse, Analyze and Manipulate Perl (without perl)")
    (description "")
    (license (package-license perl))))

(define-public perl-ppi-html
  (package
    (name "perl-ppi-html")
    (version "1.08")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "mirror://cpan/authors/id/A/AD/ADAMK/PPI-HTML-"
             version
             ".tar.gz"))
       (sha256
        (base32
         "04f5sfrb6ckfdd3lnyipmky9mdgsxr5b724sp1xaszx86d09c9l4"))))
    (build-system perl-build-system)
    (arguments
     `(#:tests? #f))
    (propagated-inputs
     `(("perl-module-install" ,perl-module-install)))
    (inputs
     `(("perl-css-tiny" ,perl-css-tiny)
       ("perl-params-util" ,perl-params-util)
       ("perl-ppi" ,perl-ppi)))
    (home-page
     "http://search.cpan.org/dist/PPI-HTML")
    (synopsis
     "Generate syntax-hightlighted HTML for Perl using PPI")
    (description "")
    (license (package-license perl))))

(define-public perl-css-tiny
  (package
    (name "perl-css-tiny")
    (version "1.20")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "mirror://cpan/authors/id/C/CH/CHORNY/CSS-Tiny-"
             version
             ".tar.gz"))
       (sha256
        (base32
         "1yjjn4li8v3d51l7jgrbbkhjdpfm9mmira2xfgf3s58wlkk9vx38"))))
    (build-system perl-build-system)
    (home-page
     "http://search.cpan.org/dist/CSS-Tiny")
    (synopsis
     "Read/Write .css files with as little code as possible")
    (description "")
    (license (package-license perl))))

(define-public cgp-pindel
  (package
    (name "cgp-pindel")
    (version "2.2.4")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/cancerit/cgpPindel/archive/v"
                    version ".tar.gz"))
              (sha256
               (base32
                "1vadlyffabqj696k9nnzqprxn5avf0a5iykpqjxmw8n2180lppvw"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-before 'build 'move-to-subdirectory
           (lambda _
             (chdir "perl")))
         (replace 'build
           (lambda* (#:key outputs #:allow-other-keys)
             (system* "perl" "Makefile.PL"
                      (string-append "PREFIX=" (assoc-ref outputs "out")))
             (system* "make"))))))
    (propagated-inputs
     `(("perl" ,perl)
       ("pcap-core" ,pcap-core)
       ("perl-cgpvcf" ,perl-cgpvcf)
       ("bioperl-minimal" ,bioperl-minimal)
       ("perl-bio-db-hts" ,perl-bio-db-hts)
       ("perl-const-fast" ,perl-const-fast)
       ("perl-file-which" ,perl-file-which)
       ("perl-pod-coverage" ,perl-pod-coverage)
       ("perl-list-moreutils" ,perl-list-moreutils)
       ("perl-test-fatal" ,perl-test-fatal)
       ("perl-try-tiny" ,perl-try-tiny)
       ("perl-capture-tiny" ,perl-capture-tiny)
       ("perl-term-ui" ,perl-term-ui)
       ("perl-log-message" ,perl-log-message)
       ("perl-ipc-system-simple" ,perl-ipc-system-simple)
       ("perl-sub-exporter-progressive" ,perl-sub-exporter-progressive)
       ("perl-devel-cover" ,perl-devel-cover)))
    (native-inputs
     `(("perl-module-install" ,perl-module-install)
       ("perl-module-build" ,perl-module-build)
       ("perl-file-sharedir-install" ,perl-file-sharedir-install)))
    (home-page "https://github.com/cancerit/cgpPindel")
    (synopsis "Cancer Genome Projects workflow for Pindel.")
    (description "")
    (license license:agpl3+)))

(define-public score-client
  (package
   (name "score-client")
   (version "5.0.0")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://artifacts.oicr.on.ca/artifactory/dcc-release/bio/"
                  "overture/score-client/" version "/score-client-" version
                  "-dist.tar.gz"))
            (sha256
             (base32 "05pvffd43aqdh92g1p37p9p00wciqxp45n5gyybxvpgs1cfdqsfm"))))
   ;; We use the GNU build system mainly for its patch-shebang phases.
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f ; This is just copying a binary, so no tests to perform.
      #:phases
      (modify-phases %standard-phases
        (delete 'configure) ; No configuration, just copying.
        (delete 'build)     ; No building, just copying.
        (replace 'install
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (let* ((out (assoc-ref outputs "out"))
                   (etc (string-append out "/etc/score-client"))
                   (bin (string-append out "/bin"))
                   (lib (string-append out "/lib")))

              (for-each mkdir-p (list out etc bin lib))

              (substitute* "bin/score-client"
               (("`dirname \\$0`/..") out)
               (("\\$\\(cd \\$\\{BASE_DIR\\} && pwd -P\\)") out)
               (("exec java") (string-append
                               "exec " (assoc-ref inputs "openjdk")
                               "/bin/java"))
               (("-Dlogging.path=\\$\\{BASE_DIR\\}/logs")
                "-Dlogging.path=${HOME}")
               (("type -p java")
                (string-append "type -p "
                               (assoc-ref inputs "openjdk")
                               "/bin/java"))
               (("_java=java")
                (string-append "_java="
                               (assoc-ref inputs "openjdk")
                               "/bin/java"))
               (("\\$\\{CLIENT_DIR\\}/conf") etc))

              (copy-recursively "bin" bin)
              (copy-recursively "conf" etc)
              (copy-recursively "lib" lib)

              (wrap-program (string-append out "/bin/score-client")
                `("_JAVA_OPTIONS" ":" = (,(string-append
                                           "-Djavax.net.ssl.trustStore="
                                           (assoc-ref inputs "openjdk")
                                           "/lib/security/cacerts"))))))))))
   (inputs
    `(("openjdk" ,openjdk11)))
   (home-page "https://docs.icgc.org/software/download/#score-client")
   (synopsis "Tool to view ICGC data")
   (description "This package provides a tool to download or view data in
the cloud environments of ICGC.")
   (license license:gpl3)))

(define-public metamaps
  (let ((commit "e23f8a8688159ff0d092557a40305dbc7acc2342"))
    (package
     (name "metamaps")
     (version (string-append "0.0-" (string-take commit 7)))
     (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/DiltheyLab/MetaMaps.git")
                    (commit commit)))
              (sha256
               (base32
                "0h9ahkv7axw4qzgbvhsz4r699swiv64hlwjy6h8s11vjls2dslrp"))))
     (build-system gnu-build-system)
     (arguments
      `(#:configure-flags (list (string-append
                                 "--with-boost="
                                 (assoc-ref %build-inputs "boost")))
        #:tests? #f
        #:phases
        (modify-phases %standard-phases
          (add-after 'unpack 'shared-boost
            (lambda _
              (substitute* "configure.ac"
               (("libboost_math_c99.a") "libboost_math_c99.so")))))))
     (native-inputs
      `(("autoconf" ,autoconf)))
     (inputs
      `(("boost" ,boost)
        ("zlib" ,zlib)
        ("gsl" ,gsl)))
     (home-page "https://github.com/DiltheyLab/MetaMaps")
     (synopsis "Long-read metagenomic analysis")
     (description "MetaMaps is tool specifically developed for the analysis
of long-read (PacBio/Oxford Nanopore) metagenomic datasets.")
     (license license:public-domain))))

(define-public iq-tree
  (package
    (name "iq-tree")
    (version "1.6.12")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/Cibiv/IQ-TREE/archive/v"
                    version ".tar.gz"))
              (sha256
               (base32 "11528sxv9hkmg20r2fy9zyq0rylbrhcjnh6cr61dwmx1wwnhj54n"))))
    (build-system cmake-build-system)
    (arguments
     `(#:configure-flags '("-DIQTREE_FLAGS=omp")
       #:tests? #f))
    (inputs
     `(("eigen" ,eigen)
       ("zlib" ,zlib)))
    (home-page "http://www.iqtree.org/")
    (synopsis "Efficient software for phylogenomic inference")
    (description
     "This package provides software for phylogenomic inference.")
    (license license:gpl2)))

(define-public last
  (package
   (name "last")
   (version "1080")
   (source (origin
            (method url-fetch)
            (uri (string-append "http://last.cbrc.jp/last-" version ".zip"))
            (sha256
               (base32
                "0az6xiqkbdcq858m1dlwvf7f7pa5fjldckkawcj8a38a2fq9drds"))))
   (build-system gnu-build-system)
   (native-inputs
    `(("unzip" ,unzip)
      ("sed" ,sed)))
   (inputs
    `(("zlib" ,zlib)))
   (arguments
    `(#:tests? #f
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (add-after 'unpack 'set-c-compiler
         (lambda* (#:key outputs #:allow-other-keys)
           (substitute* "src/makefile"
            (("# -Wconversion") "CC=gcc"))
           (substitute* "makefile"
            (("prefix = /usr/local")
             (string-append
              "prefix = " (assoc-ref outputs "out")))))))))
   (home-page "http://last.cbrc.jp/")
   (synopsis "Genome-scale sequence comparison")
   (description "")
   (license license:gpl3)))

(define-public cat
  (package
   (name "cat")
   (version "5.0.3")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/dutilh/CAT/archive/v"
                  version".tar.gz"))
            (sha256
             (base32
              "1gbq4vj0i7srylvb56ipmzcnh8zk34kfmyx76fbxh2cljp0p4k7x"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (delete 'build)
        (replace 'install
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (let ((bin (string-append (assoc-ref outputs "out") "/bin"))
                  (share (string-append (assoc-ref outputs "out") "/share/CAT")))
              (mkdir-p bin)
              (mkdir-p share)
              (with-directory-excursion "CAT_pack"
                (install-file "CAT" bin)

                ;; Don't pollute the "bin" directory with Python libraries.
                (map (lambda (file)
                       (when (string-suffix? ".py" file)
                         (install-file file share)))
                     (find-files "."))

                ;; Make sure CAT can find its Python libraries.
                (wrap-program (string-append bin "/CAT")
                 `("PYTHONPATH" ":" = (,share "$PYTHONPATH"))))))))))
   (inputs
    `(("diamond" ,diamond)
      ("prodigal" ,prodigal)
      ("python" ,python)))
   (home-page "https://github.com/dutilh/CAT")
   (synopsis "Tool for taxonomic classification of contigs and metagenome-assembled genomes")
   (description "Contig Annotation Tool (CAT) and Bin Annotation Tool (BAT)
are pipelines for the taxonomic classification of long DNA sequences and
metagenome assembled genomes (MAGs/bins) of both known and (highly) unknown
microorganisms, as generated by contemporary metagenomics studies.  The core
algorithm of both programs involves gene calling, mapping of predicted ORFs
against the nr protein database, and voting-based classification of the entire
contig / MAG based on classification of the individual ORFs.  CAT and BAT can
be run from intermediate steps if files are formated appropriately")
   (license license:expat)))

(define-public r-ascat
  (let ((commit "9fb25feaae2d7d25a17f5eff7b99666ad7afbba8"))
    (package
     (name "r-ascat")
     (version (string-append "2.5.1-" (string-take commit 7)))
     (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/Crick-CancerGenomics/ascat.git")
                    (commit commit)))
              (sha256
               (base32
                "02fxhqv4yf9dby8mmjb39fyqd141k3z4nhj0p8m2h4n7a476bdsc"))))
     (build-system r-build-system)
     (arguments
      `(#:phases
        (modify-phases %standard-phases
         (add-after 'unpack 'move-to-ascat-dir
           (lambda _
             (chdir "ASCAT"))))))
     (propagated-inputs
      `(("r-rcolorbrewer" ,r-rcolorbrewer)))
     (home-page "https://github.com/Crick-CancerGenomics/ascat")
     (synopsis "ASCAT copy number R package")
     (description "This package provides the ASCAT R package that can be used
to infer tumour purity, ploidy and allele-specific copy number profiles.")
     (license license:gpl3))))

(define-public r-cgp-battenberg
  (package
   (name "r-cgp-battenberg")
   (version "2.2.8")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/Wedge-Oxford/battenberg/archive/v"
                  version ".tar.gz"))
            (sha256
             (base32 "0gi9zv8clr795mzplf1d3dm5agc78xz40kmwckcjqaji4dnbcik1"))))
   (build-system r-build-system)
   (propagated-inputs
    `(("r-devtools" ,r-devtools)
      ("r-readr" ,r-readr)
      ("r-doparallel" ,r-doparallel)
      ("r-ggplot2" ,r-ggplot2)
      ("r-rcolorbrewer" ,r-rcolorbrewer)
      ("r-gridextra" ,r-gridextra)
      ("r-gtools" ,r-gtools)
      ("r-ascat" ,r-ascat)))
   (home-page "https://github.com/Wedge-Oxford/battenberg")
   (synopsis "Battenberg R package for subclonal copy number estimation")
   (description "This package contains the Battenberg R package for subclonal
copy number estimation.")
   (license license:gpl3)))

(define-public hiddendomains
  (package
   (name "hiddendomains")
   (version "3.1")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "mirror://sourceforge/hiddendomains/hiddenDomains."
                  version ".tar.gz"))
            (sha256
             (base32 "0kpdfz7z014aax26ga8b29s924jb8csy06lxkg3jwjdq7amy2bbw"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (delete 'build)
        (replace 'install
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (let ((bin   (string-append (assoc-ref outputs "out") "/bin"))
                  (share (string-append (assoc-ref outputs "out")
                                        "/share/hiddenDomains")))
              (mkdir-p bin)
              (for-each (lambda (file) (install-file file bin))
               '("binReads.pl"     "centersToGEM.pl" "domainsMergeToBed.pl"
                 "domainsToBed.pl" "hiddenDomains"   "peakCenters"))
              (mkdir-p share)
              (install-file "hiddenDomains.R" share)))))))
   (inputs
    `(("perl" ,perl)))
   (propagated-inputs
    `(("r-depmixS4" ,r-depmixs4)
      ("r-hiddenmarkov" ,r-hiddenmarkov)))
   (home-page "http://hiddendomains.sourceforge.net")
   (synopsis "Programs used to identify enrichment of ChIP-seq reads")
   (description "hiddenDomains is a suite of programs used to identify
significant enrichment of ChIP-seq reads that span large domains, like
HK27me3.  The input data can be in BAM format, or in a tab-delimited
'reads per bin' format described below.  The output is a BED formatted
file the lists the enriched domains and their posterior probabilities.")
   (license license:gpl2)))

(define-public perl-findbin-libs
  (package
    (name "perl-findbin-libs")
    (version "2.15")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "mirror://cpan/authors/id/L/LE/LEMBARK/FindBin-libs-"
             version ".tar.gz"))
       (sha256
        (base32
         "0306g1lpxfpv0r6491y6njjc312jx01zh2qqqa4cwkc0ya4jpdpn"))))
    (build-system perl-build-system)
    (home-page "http://search.cpan.org/dist/FindBin-libs")
    (synopsis "")
    (description "")
    (license #f)))

(define-public perl-prokka
  (package
   (name "perl-prokka")
   (version "1.14.0")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "https://github.com/tseemann/prokka/archive/v"
           version ".tar.gz"))
     (file-name (string-append name "-" version ".tar.gz"))
     (sha256
      (base32
       "1d8v52mxr61pf8pg4vw72wlq6xlfm1m0b1ds14lzr5n2xz1lgdkh"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (delete 'build)
        (replace 'install
          (lambda* (#:key inputs outputs #:allow-other-keys)
            (substitute* '("bin/prokka"
                           "bin/prokka-abricate_to_fasta_db"
                           "bin/prokka-biocyc_to_fasta_db"
                           "bin/prokka-build_kingdom_dbs"
                           "bin/prokka-cdd_to_hmm"
                           "bin/prokka-clusters_to_hmm"
                           "bin/prokka-genbank_to_fasta_db"
                           "bin/prokka-genpept_to_fasta_db"
                           "bin/prokka-hamap_to_hmm"
                           "bin/prokka-make_tarball"
                           "bin/prokka-tigrfams_to_hmm"
                           "bin/prokka-uniprot_to_fasta_db")
             (("minced ")      (string-append (assoc-ref inputs "minced")   "/bin/minced "))
             (("blastp ")      (string-append (assoc-ref inputs "blast+")   "/bin/blastp "))
             (("hmmscan ")     (string-append (assoc-ref inputs "hmmer")    "/bin/hmmscan "))
             (("hmmpress ")    (string-append (assoc-ref inputs "hmmer")    "/bin/hmmpress "))
             (("\"parallel ")  (string-append "\"" (assoc-ref inputs "parallel") "/bin/parallel "))
             (("aragorn ")     (string-append (assoc-ref inputs "aragorn")  "/bin/aragorn "))
             (("prodigal ")    (string-append (assoc-ref inputs "prodigal") "/bin/prodigal "))
             (("cmscan ")      (string-append (assoc-ref inputs "infernal") "/bin/cmscan "))
             (("cmpress ")     (string-append (assoc-ref inputs "infernal") "/bin/cmpress "))
             (("makeblastdb ") (string-append (assoc-ref inputs "blast+")   "/bin/makeblastdb ")))

            (mkdir-p (string-append (assoc-ref outputs "out") "/bin"))
            (copy-recursively "bin" (string-append (assoc-ref outputs "out") "/bin"))
            (mkdir-p (string-append (assoc-ref outputs "out") "/share/prokka/db"))
            (copy-recursively "db" (string-append (assoc-ref outputs "out") "/share/prokka/db"))

            (for-each (lambda (program)
                        (wrap-program program
                          `("PERL5LIB" ":" = (,(getenv "PERL5LIB") "$PERL5LIB"))))
                      (find-files (string-append (assoc-ref outputs "out") "/bin"))))))))
   (inputs
    `(("perl" ,perl)
      ("perl-time-piece" ,perl-time-piece)
      ("perl-xml-simple" ,perl-xml-simple)
      ("perl-digest-md5" ,perl-digest-md5)
      ("perl-module-build" ,perl-module-build)
      ("perl-data-dumper" ,perl-data-dumper)
      ("bioperl-minimal" ,bioperl-minimal)
      ("perl-findbin-libs" ,perl-findbin-libs)
      ("perl-scalar-list-utils" ,perl-scalar-list-utils)
      ("parallel" ,parallel)
      ("aragorn" ,aragorn)
      ("blast+" ,blast+)
      ("hmmer" ,hmmer)
      ("prodigal" ,prodigal)
      ("infernal" ,infernal)
      ("minced" ,minced)
      ("findutils" ,findutils)
      ("icedtea" ,icedtea-8)))
   (native-search-paths
    (list (search-path-specification
           (variable "PROKKA_DBDIR")
           (files '("share/prokka/db")))))
   (home-page "https://github.com/tseemann/prokka")
   (synopsis "Rapid prokaryotic genome annotation")
   (description "This package provides tools for rapid prokaryotic
genome annotation.")
   (license license:gpl3)))

(define-public cgp-cavemanwrapper-1.15.2
  (package
   (name "cgp-cavemanwrapper")
   (version "1.15.2")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://github.com/cancerit/cgpCaVEManWrapper/archive/"
                  version ".tar.gz"))
            (file-name (string-append name "-" version ".tar.gz"))
            (patches (list (search-patch "cgp-cavemanwrapper-fix-script.patch")))
            (sha256
             (base32
              "017b03j1sm64v6barbxx69420d3s1gx5nlcqg7rzn6mczj47g264"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f
      #:phases
      (modify-phases %standard-phases
       (delete 'configure)
       (delete 'install)
       ;; The Perl in Guix does not support threads.
       ;; The forks module is a drop-in replacement for it, so it
       ;; is easier to use that instead of recompiling Perl.
       (add-after 'unpack 'enable-threads
        (lambda _
          (substitute* "bin/caveman_merge_results.pl"
           (("use strict;") "use forks;\nuse strict;"))))
       (replace 'build
        (lambda* (#:key inputs outputs #:allow-other-keys)
          (let ((bin-dir (string-append (assoc-ref outputs "out") "/bin"))
                (lib-dir (string-append (assoc-ref outputs "out")
                                        "/lib/perl5/site_perl/5.28.0")))
            (mkdir-p bin-dir)
            (mkdir-p lib-dir)
            (install-file "bin/caveman_merge_results.pl" bin-dir)
            (copy-recursively "lib/Sanger" lib-dir)
            #t))))))
   (propagated-inputs
    `(("perl-file-path" ,perl-file-path)
      ("perl-file-which", perl-file-which)
      ("perl-const-fast", perl-const-fast)
      ("perl-capture-tiny", perl-capture-tiny)
      ("perl-ipc-system-simple", perl-ipc-system-simple)
      ("perl-try-tiny", perl-try-tiny)
      ("perl-carp", perl-carp)
      ("perl-forks", perl-forks)
      ("pcap-core" ,pcap-core)
      ("perl" ,perl)))
   (home-page "https://github.com/cancerit/cgpCaVEManWrapper")
   (synopsis "Reference implementation of CGP workflow for CaVEMan")
   (description "This package provides the reference implementation of CGP
workflow for CaVEMan SNV analysis.")
   (license license:agpl3+)))

(define-public beta
  (package
    (name "beta")
    (version "1.0.7")
    (source (origin
              (method url-fetch)
              (uri "http://cistrome.org/BETA/src/BETA_1.0.7.zip")
              (sha256
               (base32 "0axnq7mjj8b7v3fkyh7vp4gq1h252czxakc914zvii10i6kmjkh1"))))
    (build-system python-build-system)
    (arguments
     `(#:tests? #f
       #:python ,python-2
       #:phases
       (modify-phases %standard-phases
         (replace 'unpack
           (lambda* (#:key inputs #:allow-other-keys)
             (let ((unzip (string-append (assoc-ref inputs "unzip")
                                         "/bin/unzip")))
               (system* unzip (assoc-ref %build-inputs "source")
                        "-C" "BETA_1.0.7/*")
               (chdir "BETA_1.0.7"))))
         (add-after 'unpack 'fix-compiler-invocation
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "BETA/misp/Makefile"
               (("CC = cc") (string-append "CC = " (assoc-ref inputs "gcc")
                                           "/bin/gcc")))))
         (add-after 'unpack 'fix-rscript-path
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "BETA/Up_Down_score.py"
               (("Rscript") (string-append (assoc-ref inputs "r")
                                           "/bin/Rscript")))
             (substitute* "BETA/Up_Down_distance.py"
               (("Rscript") (string-append (assoc-ref inputs "r")
                                           "/bin/Rscript"))))))))
    (native-inputs
     `(("unzip" ,unzip)
       ("gcc" ,gcc)))
    (inputs
     `(("python2-numpy" ,python2-numpy)
       ("zlib" ,zlib)
       ("r" ,r-minimal)))
    (home-page "http://cistrome.org/BETA/")
    (synopsis "Binding and Expression Target Analysis")
    (description "Binding and Expression Target Analysis (BETA) is a software
package that integrates ChIP-seq of transcription factors or chromatin
regulators with differential gene expression data to infer direct target
genes.  BETA has three functions: (1) to predict whether the factor has
activating or repressive function; (2) to infer the factor’s target genes;
and (3) to identify the motif of the factor and its collaborators which might
modulate the factor’s activating or repressive function.  Here we describe the
implementation and features of BETA to demonstrate its application to several
datasets.  BETA requires ~2GB RAM and 1h for the whole procedure.")
    (license license:artistic2.0)))

(define-public python-ont-tombo
  (package
    (name "python-ont-tombo")
    (version "1.5.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "ont-tombo" version))
       (sha256
        (base32
         "1023hadgcsgi53kz53ql45207hfizf9sw57z0qij3ay1bx68zbpm"))))
    (build-system python-build-system)
    (native-inputs
     `(("python-cython" ,python-cython)
       ("python-nose2" ,python-nose2)
       ("python-tqdm" ,python-tqdm)))
    (propagated-inputs
     `(("python-future" ,python-future)
       ("python-h5py" ,python-h5py)
       ("python-mappy" ,python-mappy)
       ("python-numpy" ,python-numpy)
       ("python-scipy" ,python-scipy)))
    (home-page "https://github.com/nanoporetech/tombo")
    (synopsis "Analysis of raw nanopore sequencing data")
    (description "Analysis of raw nanopore sequencing data.")
    ;; In addition, some of the source code form may contain derivative works of
    ;; nanoraw licensed under the licence from The Regents of the University of
    ;; California, terms of which are included below.
    (license license:mpl2.0)))

(define-public python-checkm-genome
  (package
   (name "python-checkm-genome")
   (version "1.1.3")
   (source (origin
            (method url-fetch)
            (uri (pypi-uri "checkm-genome" version))
            (sha256
             (base32
              "0i2nnki639hgjag17wlva2x0ymn37b4krqsf6akxddykhfbkdnkz"))))
   (build-system python-build-system)
   ;; Tests fail due to missing data. More investigation is needed.
   (arguments
    `(#:tests? #f))
   (propagated-inputs
    `(("python-dendropy" ,python-dendropy)
      ("python-matplotlib" ,python-matplotlib)
      ("python-numpy" ,python-numpy)
      ("python-pysam" ,python-pysam)
      ("python-scipy" ,python-scipy)))
   (home-page "http://pypi.python.org/pypi/checkm/")
   (synopsis "Assess the quality of putative genome bins.")
   (description "Assess the quality of putative genome bins.")
   (license license:gpl3)))
