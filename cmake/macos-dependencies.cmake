set(SYSTEM_HAS_SPDLOG TRUE)
set(BREW_DEPENDENCIES
  coreutils
  pkg-config
  gnu-sed
  wget
  python
  cmake
  doxygen
  libtool
  tinyxml2
  geos
  boost
  eigen
  nanomsg
  yaml-cpp
  qt
  qwt
  pyqt
  gcc
  spdlog
  ninja
)
if(BUILD_BENCHMARKS)
  list(APPEND BREW_DEPENDENCIES google-benchmark)
endif()
set(PIP_DEPENDENCIES Cython coverage nose numpy matplotlib)
if(WITH_ROS_SUPPORT AND NOT DEFINED ENV{ROS_DISTRO})
  message(FATAL_ERROR "ROS support is enabled but ROS_DISTRO is not set. Please source the setup before continuing or disable ROS support.")
endif()

if(INSTALL_SYSTEM_DEPENDENCIES)
  find_program(BREW brew)
  if(NOT BREW)
    execute_process(COMMAND /bin/bash -c /bin/bash -c "\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
    find_program(BREW brew)
    if(NOT BREW)
      message(FATAL_ERROR "Installation of Homebrew failed, check the output above or install Homebrew yourself: https://brew.sh/")
    endif()
  endif()
  execute_process(COMMAND ${BREW} update)
  execute_process(COMMAND ${BREW} install ${BREW_DEPENDENCIES})
  execute_process(COMMAND ${BREW} upgrade ${BREW_DEPENDENCIES})
  # Temporary fix for the macOS setup on github actions
  execute_process(COMMAND brew unlink gfortran)
  execute_process(COMMAND brew link gfortran)
  if(PYTHON_BINDING)
    if(PYTHON_BINDING_BUILD_PYTHON2_AND_PYTHON3)
      execute_process(COMMAND pip2 install ${PIP_DEPENDENCIES})
      execute_process(COMMAND pip3 install ${PIP_DEPENDENCIES})
    elseif(PYTHON_BINDING_FORCE_PYTHON2)
      execute_process(COMMAND pip2 install ${PIP_DEPENDENCIES})
    elseif(PYTHON_BINDING_FORCE_PYTHON3)
      execute_process(COMMAND pip3 install ${PIP_DEPENDENCIES})
    else()
      execute_process(COMMAND pip install ${PIP_DEPENDENCIES})
    endif()
  endif()
endif()
