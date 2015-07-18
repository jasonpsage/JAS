<?

	include_once('../php/iwf.php');

//	$iwf->debug(true);

	$iwf->addJavascript("alert(window.name);");

	$pic = $_FILES['filPic'];


	$output = '';

	if (!isset($pic)) {
		$output .= 'filPic not uploaded.';
	} else {

		if ($pic['error'] == UPLOAD_ERR_NO_FILE){
			$output .= 'ERROR!  No file!';
		}

		if ($pic['error'] == UPLOAD_ERR_PARTIAL){
			$output .= 'ERROR!  Partial file!';
		}

		if ($pic['error'] == UPLOAD_ERR_FORM_SIZE){
			$output .= 'ERROR!  File size exceeds limit specified in form!';
		}

		if ($pic['error'] == UPLOAD_ERR_INI_SIZE){
			$output .= 'ERROR!  File size exceeds limit set in php.ini!';
		}

		if ($pic['error'] == UPLOAD_ERR_OK){
			$output .= 'Worked!  File uploaded. (temp name is ' . $pic['tmp_name'] . ')';
		}

	}

	$output .= UPLOAD_ERR_NO_FILE;
	$output .= UPLOAD_ERR_PARTIAL;
	$output .= UPLOAD_ERR_FORM_SIZE;
	$output .= UPLOAD_ERR_INI_SIZE;
	$output .= UPLOAD_ERR_OK;

	$iwf->addHtml("Posted file: $output", 'iwfContent');

	$iwf->close();

?>