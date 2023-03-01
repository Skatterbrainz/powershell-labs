param (
	$InputFile = "c:\git\powershell-labs\openai\words.csv"
)

if (!(Test-Path $InputFile)) {
	Write-Warning "File not found: $InputFile"
	break
}

function Get-Embedding {
	[CmdletBinding()]
	param([string]$prompt)
	$headers = @{
		'Content-Type' = 'application/json'
		Authorization = "Bearer $($env:OpenAIKey)"
	}
	$body = @{
		input = $prompt
		model = "text-embedding-ada-002"
	} | ConvertTo-Json
	$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body 
	$response.data.embedding
}

function Get-SearchVectors {
	[CmdletBinding()]
	param()
	$df = Import-Csv $InputFile
	$newcsv = [system.collections.arraylist]::new()

	$df | foreach-object {
		write-verbose "-- word: $($_.text)"
		$emb = Get-Embedding $_.text
		[pscustomobject]@{
			text = $_.text
			embedding = $emb
		}
	}
}

function Measure-VectorSimilarity {
	<#PSScriptInfo
	.DESCRIPTION Measures the vector / cosine similarity between two sets of items. 
	.VERSION 1.0.0
	.GUID e1f78756-d1bc-47b4-8d88-475ace119a69
	.AUTHOR Lee Holmes
	#>

	<#
	.SYNOPSIS

	Measures the vector / cosine similarity between two sets of items.
	See: https://en.wikipedia.org/wiki/Cosine_similarity

	.EXAMPLE

	PS > .\Measure-VectorSimilarity.ps1 @(1..10) @(3..8)
	0.775

	.EXAMPLE

	PS > $items = dir c:\windows\ | Select -First 10
	PS > $items2 = dir c:\windows\ | Select -First 8
	PS > .\Measure-VectorSimilarity.ps1 $items $items2 -KeyProperty Name -ValueProperty Length
	0.894
	#>

	[CmdletBinding()]
	param(
		## The first set of items to compare
		[Parameter(Position = 0)]
		$Set1,

		## The second set of items to compare
		[Parameter(Position = 1)]   
		$Set2,
		
		## If the item sets represent objects that have a main property
		## (like file names), the name of that key property 
		[Parameter()]
		$KeyProperty,

		## If the item sets represent objects that have a main property
		## to represent the values (like Count or Percent),
		## the name of that key property. If they don't have a property
		## like this, simple existence of the item will be used. 
		[Parameter()]
		$ValueProperty
	)

	## If either set is empty, there is no similarity
	if((-not $Set1) -or (-not $Set2))
	{
		return 0
	}

	## Figure out the unique set of items to be compared - either based on
	## the key property (if specified), or the item value directly
	$allkeys = @($Set1) + @($Set2) | Foreach-Object {
		if($PSBoundParameters.ContainsKey("KeyProperty")) { $_.$KeyProperty}
		else { $_ }
	} | Sort-Object -Unique

	## Figure out the values  of items to be compared - either based on
	## the value property (if specified), or the item value directly. Put
	## these into a hashtable so that we can process them efficiently.

	$set1Hash = @{}
	$set2Hash = @{}
	$setsToProcess = @($Set1, $Set1Hash), @($Set2, $Set2Hash)

	foreach($set in $setsToProcess)
	{
		$set[0] | Foreach-Object {
			if($PSBoundParameters.ContainsKey("ValueProperty")) { $value = $_.$ValueProperty }
			else { $value = 1 }
			
			if($PSBoundParameters.ContainsKey("KeyProperty")) { $_ = $_.$KeyProperty }

			$set[1][$_] = $value
		}
	}

	## Calculate the vector / cosine similarity of the two sets
	## based on their keys and values.
	$dot = 0
	$mag1 = 0
	$mag2 = 0

	foreach($key in $allkeys)
	{
		$dot += $set1Hash[$key] * $set2Hash[$key]
		$mag1 +=  ($set1Hash[$key] * $set1Hash[$key])
		$mag2 +=  ($set2Hash[$key] * $set2Hash[$key])
	}

	$mag1 = [Math]::Sqrt($mag1)
	$mag2 = [Math]::Sqrt($mag2)

	## Return the result
	[Math]::Round($dot / ($mag1 * $mag2), 3)
}

Write-Host "getting word list vectors..."
$word_vectors = Get-SearchVectors

Write-Host "getting hot dog vectors..."
$hotdog_vector = Get-Embedding "hot dog"

function Get-SimilarVector {
	param (
		$SearchVectors,
		$WordVector
	)
	$SearchVectors | % {
		Measure-VectorSimilarity -Set1 $_ -Set2 $WordVector
	}
}
