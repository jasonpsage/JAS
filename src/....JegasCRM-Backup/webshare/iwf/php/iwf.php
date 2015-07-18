<?
class IWFAction {

	var $type;
	var $target;
	var $code;
	var $msg;
	var $content;
	var $emitted;

	function IWFAction($type, $target, $content){
		$this->type = $type;
		$this->target = $target;
		$this->emitted = false;
		$this->content = $content;
	}

	function error($code, $msg){
		$this->code = $code;
		$this->msg = $msg;
		$this->content = '';
		return $this;
	}

	function _echoStart($prettyprint){
		if ($prettyprint){
			echo "\n\t";
		}
		echo "<action type='$this->type'";
		if ($this->target){
			echo " target='$this->target'";
		}
		if ($this->errorCode){
			echo " errorCode='$this->code'";
		}
		if ($this->message){
			echo " message='$this->message'";
		}
		echo '>';
		if ($prettyprint){
			echo "\n\t\t";
		}
		// once we echo any part of this object, we must not re-echo it,
		// so mark this object as emitted.
		$this->emitted = true;
		return $this;
	}

	function _echoEnd($prettyprint){
		if ($prettyprint){
			echo "\n\t";
		}
		echo "</action>";
		return $this;
	}

	function emit($echoEnd, $prettyprint){
		if (!$this->emitted){
			$this->_echoStart($prettyprint);
			echo $this->content;
		}
		if ($echoEnd){
			$this->_echoEnd($prettyprint);
		}
		return $this;
	}
}

class IWFController {

	var $actions;
	var $currentAction;
	var $currentlyEmitting;
	var $startedEmitting;
	var $debugging;
	var $prettyprint;
	var $iframeName;

	function IWFController(){
		if ($iwf){
			alert("Do not create new IWFController objects.\nThe singleton stored in $iwf should be used instead.");
			return;
		}
		$this->actions = array();
		$this->currentAction = null;
		$this->currentlyEmitting = '';
		$this->startedEmitting = false;
		$this->debugging = false;
		$this->prettyprint = false;
		$this->iframeName = '';
	}

	function debug($on){
		$this->debugging = $on;
		if ($on){
			$this->prettyprint = true;
		}
	}

	function pretty($on){
		$this->prettyprint = $on;
	}

	function iframe($name){
		$this->iframeName = $name;
	}

	function startAction($type, $target){
		// ensure we've emitted everything up until this point...
		$this->_emit(false);
		$this->currentAction = new IWFAction($type, $target, '');
		$this->currentAction->emit(false, $this->prettyprint);
		$this->currenltyEmitting = $type;
		return $this->currentAction;
	}

	function endAction(){
		if ($this->currentAction){
			$this->currentAction->emit(true, $this->prettyprint);
			$this->currentlyEmitting = '';
			$this->currentAction = null;
		} else {
			echo "called end action when no action was current!";
		}
		return null;
	}

	function addHtml($html, $target){
		$act = new IWFAction('html', $target, $html);
		array_push($this->actions, $act);
		return $act;
	}

	function startHtml($target){
		return $this->startAction('html', $target);
	}

	function endHtml($close){
		if ($this->currentlyEmitting != 'html'){
			$this->error(-2163, 'iwf.endHtml() called, but iwf believes it should be emitting ' . $this->currentlyEmitting);
		} else {
			$this->endAction();
		}

		if ($close){
			$this->close();
		}
	}

	function error($code, $msg){
		if ($this->currentAction){
			$this->currentAction->error($code, $msg);
		} else {
			$this->addError($code, $msg);
		}
	}

	function endXml($finished){
		if ($this->currentlyEmitting != 'html'){
			$this->error(-2164, 'iwf.endXml() called, but iwf believes it should be emitting ' . $this->currentlyEmitting);
		} else {
			$this->endAction();
		}
		if (isset($finished) && $finished){
			$this->close();
		}
	}

	function addJavascript($js){
//		$act = new IWFAction('javascript', '', "<![CDATA[ $js ]]>" );
		$act = new IWFAction('javascript', '', "<!-- $js //-->" );
		array_push($this->actions, $act);
		return $act;
	}

	function popup($txt){
		return $this->addJavascript("alert('Server-side IWF popup:\\n$txt')");
	}

	function addXml($xml){
		$act = new IWFAction('xml', '', $xml);
		array_push($this->actions, $act);
		return $act;
	}

	function startXml(){
		return $this->startAction('xml', '');
	}

	function addError($code, $msg){
		$act = new IWFAction('','','');
		$act->error($code, $msg);
		array_push($this->actions, $act);
		return $act;
	}

	function _emit($emitEnd){
		if (!$this->startedEmitting){
			if ($this->iframeName != ''){
				echo "<html><head></head><body onload='javascript:window.parent._iwfIframeCallback(\"";
				echo $this->iframeName;
				echo "\", document.body.innerHTML);' >";
			}
			echo "<response";
			if ($this->debugging){
				echo " debugging='true'";
			}
			if ($this->prettyprint){
				echo " pretty='true'";
			}
			echo ">";
			$this->startedEmitting = true;
		}

		if ($this->currentAction){
			$this->endAction();
		}

		foreach($this->actions as $act){
			$act->emit(true, $this->prettyprint);
		}

		// empty the array, as we've emitted it and cannot go back anymore...
		$this->actions = array();

		if ($emitEnd){
			if ($this->prettyprint){
				echo "\n";
			}
			echo "</response>";
			if ($this->prettyprint){
				echo "\n";
			}
			if ($this->iframeName != ''){
				echo "</body></html>";
			}
		}
	}


	function close(){
		$this->_emit(true);
		$this->debugging = false;
	}

}

//function iwfXmlEncode($s){
//	return str_replace('"', '&quot;', str_replace("'", "&apos;", str_replace('>', '&gt;', str_replace('<', '&lt;', str_replace('&', '&amp;', $s)))));
//}

//function iwfXmlDecode($s){
//	return str_replace('&quot;', '"', str_replace('&apos;', "'", str_replace('&gt;', '>', str_replace('&lt;', '<', str_replace('&amp;', '&', $s)))));
//}

// create a singleton IWF object to use
$iwf = new IWFController();

$iwfIframeName = strtolower(@$_REQUEST['iwfIframeName']) . '';
$iwf->iframe($iwfIframeName);

$iwfPretty = strtolower(@$_REQUEST['iwfPretty']) == 'true';
$iwf->pretty($iwfPretty);

// debugging always sets prettyprint to true, so we must set debug last.
$iwfDebug = strtolower(@$_REQUEST['iwfDebug']) == 'true';
$iwf->debug($iwfDebug);



// load the default vars...
$iwfMode = strtolower(@$_REQUEST['iwfMode']);
$iwfId = @$_REQUEST['iwfId'];

$iwfTarget = @$_REQUEST['iwfTarget'];

//if (!isset($iwfTarget)){
//	$iwfTarget = 'iwfContent';
//}

?>