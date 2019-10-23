
#Requires -Version 4

#Data-Type used in param
#[string]    Fixed-length string of Unicode characters
# [char]      A Unicode 16-bit character
# [byte]      An 8-bit unsigned character
# [int]       32-bit signed integer
# [long]      64-bit signed integer
# [bool]      Boolean True/False value
# [decimal]   A 128-bit decimal value
# [single]    Single-precision 32-bit floating point number
# [double]    Double-precision 64-bit floating point number
# [DateTime]  Date and Time
# [xml]       Xml object
# [array]     An array of values
# [hashtable] Hashtable object


param(
   [string] $source,
   [string] $imageFile
   #[string]$val1
   #[string]$val2 ...
)

#$change_form = "$pwd\test.pdf"
[string] $output_filename = "H:\result.pdf"

#Add-Type -Path ".\itextsharp.dll"
[System.Reflection.Assembly]::LoadFrom("H:\powershell\itext.kernel.dll")
[System.Reflection.Assembly]::LoadFrom("H:\powershell\itext.io.dll")
# [System.Reflection.Assembly]::LoadFrom("H:\powershell\Common.Logging.Core.dll")
# [System.Reflection.Assembly]::LoadFrom("H:\powershell\Common.Logging.dll")
[System.Reflection.Assembly]::LoadFrom("H:\powershell\itext.forms.dll")
[System.Reflection.Assembly]::LoadFrom("H:\powershell\itext.layout.dll")
[System.Reflection.Assembly]::LoadFrom("H:\powershell\BouncyCastle.Crypto.dll")
# Add-Type -Path ".\itext.kernel.dll"
# Add-Type -Path ".\itext.io.dll"
# Add-Type -Path ".\Common.Logging.Core.dll"
# Add-Type -Path ".\Common.Logging.dll"

$reader = [iText.Kernel.Pdf.PdfReader]::new($source)
# $reader = New-Object iText.Kernel.Pdf.PdfReader -ArgumentList $source


$PdfDocument = [iText.Kernel.Pdf.PdfDocument]::new($reader, [iText.Kernel.Pdf.PdfWriter]::new($output_filename))
$document = [iText.Layout.Document]::new($PdfDocument)
$pdf_fields = @{
	#'field1' = $val1
	#'field2' = $val2
	#....
}

$form = [iText.forms.PdfAcroForm]::getAcroForm($PdfDocument, 1)
$image_field = $form.getField("topmostSubform[0].Page1[0].f1_1[0]")
$widgetAnnot = $image_field.getWidgets()[0]
[array]$annotRect = $widgetAnnot.GetRectangle()


$imgData = [iText.io.Image.ImageDataFactory]::create("H:\powershell\google.png")
$image = [iText.Layout.Element.Image]::new($imgData)
$image.ScaleToFit($annotRect[2].FloatValue()-$annotRect[0].FloatValue(), $annotRect[3].FloatValue()-$annotRect[1].FloatValue())
$image.setFixedPosition($annotRect[0].FloatValue(), $annotRect[1].FloatValue())
$form.removeField("topmostSubform[0].Page1[0].f1_1[0]")
[array] $form_fields = $form.getFormFields()
# $form_fields
for ($i=0; $i-lt @($args).length; $i++) {
	
		# $form_keys[0][$i]
		
		 # $form_fields[$i].Key
	 $pdf_fields.Add($form_fields[$i].Key, $args[$i])
}

# $pdf_fields
foreach ($field in $pdf_fields.GetEnumerator()) {
	# $field.count
	# $form.getField($field.Key).getValue()
	$form.getField($field.Key).setValue($field.Value)
	# write-output $field.Key
	
}
# $image.setFixedPosition(400, 300)
# $image.scaleAbsolute(20,50)
# $page = $PdfDocument.GetPage(1)

# $canvas = [iText.Kernel.Pdf.Canvas.PdfCanvas]::new($PdfDocument, 1)
# $canvas.AddImage($image, 100.0, 100.0, 100.0, 200.0, 200.0, 200.0)
# $PdfDocument.addImage($image)
$document.add($image)
## Close
$document.Close()
$PdfDocument.Close();


#write-host $reader.acrofields.getfield("topmostSubform[0].Page1[0].FederalClassification[0].c1_1[0]")
#$Reader.Close() 

#Guide
#Customize output_filename
#Command line .\editpdf.ps1 -source URL val1 val2 val3 ...
#eg  .\editpdf.ps1 -source H:\powershell\test.pdf -image H:\powershell\google.png "" 0 0 0 0 0 0 0 0 0 0 0
#0 0 0 0 0 0 0 0

#Checkbox val true:1 false:0
#You can see what kind of form fields in the pdf file by uncommenting line 59 $form_fields
#In case of can't run ps1 file: 
#run one of these Set-ExecutionPolicy RemoteSigned / Set-ExecutionPolicy RemoteSigned AllSigned in CMD

