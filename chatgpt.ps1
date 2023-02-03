import-module PowerShellAI
#$env:OpenAIKey = ""

$question = @'
return a list of US states showing name, abbreviation, year addded to the US, and output as JSON
'@

Enable-AIShortCutKey
Get-GPT3Completion -prompt $question -model "text-davinci-003" -temperature 1 -max_tokens 2500

<#
$header = @{
	Authorization = "Bearer $($env:OpenAIKey)"
	OpenAI-Organization = "$($env:OpenAIOrg)""
}
#>