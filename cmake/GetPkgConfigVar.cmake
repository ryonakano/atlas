# - try to get pkgconfig variables
#
# Copyright (C) 2010, Pino Toscano, <pino@kde.org>
# Copyright (C) 2014, Corentin Noël, <tintou@mailoo.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

macro(GET_PKGCONFIG_VAR _outvar _varname _filename)
  execute_process(
    COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=${_varname} ${_filename}
    OUTPUT_VARIABLE _result
    RESULT_VARIABLE _null
  )

  if (_null)
  else()
    string(REGEX REPLACE "[\r\n]" " " _result "${_result}")
    string(REGEX REPLACE " +$" ""  _result "${_result}")
    separate_arguments(_result)
    set(${_outvar} ${_result} CACHE INTERNAL "")
  endif()
endmacro(GET_PKGCONFIG_VAR)