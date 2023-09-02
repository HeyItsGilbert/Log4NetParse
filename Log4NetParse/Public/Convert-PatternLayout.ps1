function Convert-PatternLayout {
  [CmdletBinding()]
  param (
    [string]
    $PatternLayout = '%timestamp [%thread] %level %logger %ndc - %message%newline'
    # This is the DetailPattern https://logging.apache.org/log4net/release/sdk/?topic=html/T_log4net_Layout_PatternLayout.htm#Remarks
  )
  # Regex to identiy pattern names
  # Conversions are '%' + formater + conversion pattern name
  # Formatter start with `.` or `-` and numbers or range
  # https://rubular.com/r/r9jtIzuxJag0HV
  [regex]$patternRegex = '%(?<right_justify>-)?(?<min_width>\d+)?\.?(?<max_width>\d+)?(?<name>\w+)'
  # This wonky replace replaces any special characters so they don't mess up the regex later
  $regExString = "^" + ($PatternLayout -replace '([\\\*\+\?\|\{\}\[\]\(,)\^\$\.\#]\B)','\$1' ) + "$"

  $conversions = $patternRegex.Matches($PatternLayout)
  foreach ($conversion in $conversions) {
    $name = $conversion.Groups['name'].Value

    $conRegex = switch ($name) {
      '%' { '%' }
      { @('appdomain', 'a') -contains $_ } { '\w+' }
      { @('logger', 'c') -contains $_ } { '\w+' }
      { @('type', 'C', 'class') -contains $_ } { '\w+' }
      { @('date', 'd', 'utcdate') -contains $_ } {
        # This has it's own modifiers.
        '\d{4}-\d{2}-\d{2} [0-9:]{8},\d{3}'
      }
      { @('file', 'F') -contains $_ } { '\w+' }
      { @('level', 'p') -contains $_ } { '\w+' }
      { @('location', 'l') -contains $_ } { '\w+' }
      { @('line', 'L') -contains $_ } { '\w+' }
      { @('message', 'm') -contains $_ } { '.*' }
      { @('method', 'M') -contains $_ } { '\w+' }
      { @('newline', 'n') -contains $_ } { '\n' }
      { @('property', 'properties', 'P') -contains $_ } { '\w+' }
      { @('timestamp', 'r') -contains $_ } { '\d+' }
      { @('thread', 't') -contains $_ } { '\d+' }
      { @('identity', 'u') -contains $_ } { '\w+' }
      { @('mdc', 'X') -contains $_ } { '\w+' }
      { @('ndc', 'x') -contains $_ } { '\w+' }
      { @('username', 'w') -contains $_ } { '\w+' }
      'aspnet-cache' { '(?<aspnet-cache>\w+)' }
      'aspnet-context' { '(?<aspnet-context>\w+)' }
      'aspnet-request' { '(?<aspnet-request>\w+)' }
      'aspnet-session' { '(?<aspnet-session>\w+)' }
      'exception' { '\w+' }
      'stacktrace' { '\w+' }
      'stacktracedetail' { '\w+' }
      Default { throw "Unknown conversion pattern name: $name"}
    }

    # If we detected any of the formatting bits, let's use them.
    if(
      $conversion.Groups['right_justify'].Success -Or
      $conversion.Groups['min_width'].Success -Or
      $conversion.Groups['max_width'].Success
    ) {
      $formatString = '{'
      # Determine the padding/truncating
      if($conversion.Groups['min_width'].Success){
        $formatString += $conversion.Groups['min_width'].Value
      } else {
        $formatString += '0'
      }

      $formatString += ','

      if($conversion.Groups['max_width'].Success){
        $formatString += $conversion.Groups['max_width'].Value
      }
      else {
        # Nothing, this means it can be as long as it wants
      }
      $formatString += '}'

      # Determine where to add the space
      if($conversion.Groups['right_justify'].Success){
        $regExGroup = "(?<{0}>(?=.{2}\b){1}\s*)" -F  $name, $conRegex, $formatString
      } else {
        # If given only a max width & no right justify then there is no spacing
        # This means truncate after N letters.
        if($conversion.Groups['min_width'].Success -eq $False){
          $regExGroup = "(?<{0}>(?=.{2}\b){1})" -F  $name, $conRegex, $formatString
        } else {
          $regExGroup = "(?<{0}>(?=.{2}\b)\s*{1})" -F  $name, $conRegex, $formatString
        }
      }
    } else {
      $regExGroup = "(?<{0}>{1})" -F $name, $conRegex
    }

    # Replace the original pattern with our regex
    $regExString = $regExString.replace($conversion.Value, $regExGroup)
  }

  return [regex]$regExString
}
