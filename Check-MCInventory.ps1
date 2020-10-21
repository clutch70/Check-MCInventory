########################################################################
#																		
#	Script Title: Check-MCInventory											
#	Author: Brennan Custard												
#	Date: 10/21/2020														
#	Description: This script accepts a MicroCenter product URL and 
#	returns the inStock status			 		
#																		
########################################################################
#
#	Assumptions
#	Your product URI will be formatted similarly to the example below
#	https://www.microcenter.com/product/608318/amd-ryzen-7-3700x-matisse-36ghz-8-core-am4-boxed-processor-with-wraith-prism-cooler
#	Your mileage may vary based on the selected store/future site updates/etc...
#	If you do not specify repeatCount, you only want to check once
#	If you do not specify repeatInterval, the default wait is 30 seconds in between checks
#
#


param ($productUri, $repeatCount=1, $repeatInterval=30)
$counter = 1

function getMcHtml
	{
		$date = Get-Date
		$request = Invoke-WebRequest -URI $productUri
		$request = $request.toString() -split "[`r`n]"
		$request = $request | Select-String "'inStock'"
		
		IF ($request -like "*False*")
			{
				write-output "Item is not in stock at $date..."
				#write-output "Test result is $request"
				$inStock = $false
			}
		IF ($request -like "*True*")
			{
				write-output "Item is in stock as of $date!!!"
				[console]::beep(1000,500)
				[console]::beep(1000,500)
				[console]::beep(1000,500)
				#write-output "Test result is $request"
				$inStock = $true
				pause
				exit
			}
		
		return $inStock
	}

DO
	{
		IF ($counter -ne 1)
			{
				#Write-Output "Last stock status was $inStock..."
				Write-Output "Sleeping $repeatInterval seconds..."
				Start-Sleep -seconds $repeatInterval
			}
		getMcHtml($productUri)
		$counter = $counter + 1
		
	
	} WHILE ($counter -le $repeatCount)