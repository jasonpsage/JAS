//==============================================================================
// Jegas Application Server Configuration
//==============================================================================
var URL_USRAPI='http://10.1.10.3/?usrapi=';
//==============================================================================
// Jegas Application Server Configuration
//==============================================================================

//==============================================================================
// GLOBAL
//==============================================================================
var USRAPI=null;// class instance used globally for USRAPI interaction
//==============================================================================


//==============================================================================
// USR API - Javascript Side
//==============================================================================
var USRAPI=null;
function clsUSRAPI(){
  this.doc=null;
  this.SessionUID="0";
  this.iwfCallback=function(p_doc){
    USRAPI.doc=p_doc;//purposely not "this"
  };
  this.USRAPIURL=function(p_USRAPI_Function){
    var jsid=null;
    var iP=window.location.href.toUpperCase().indexOf('JSID=');
    if(iP>-1){
      jsid=window.location.href.substr(iP+5);
    }else{
      jsid=readCookie('JSID');
    };
    var sCall=URL_USRAPI+p_USRAPI_Function;
    if(jsid!=null){sCall+='&jsid='+jsid;};
    return sCall;
  };
  
  this.iRowIndexWithName=function(p_name){
    var ix=0;
    if(this.doc.rows[0].row.length>0){
      try{
        while((this.doc.rows[0].row[ix].name[0].getText()!=p_name)&&(ix<this.doc.rows[0].row.length-1)){
          ix++;
        };
        if(this.doc.rows[0].row[ix].name[0].getText()!=p_name){
          ix=-1;
        };
      }catch(e){
        alert(e.message + ' ix:'+ix.toString()+' doc:'+this.doc);
      };
    }else{
      ix=-1;
    };
    return ix;
  };
  
  // returns helloworld text
  this.helloworld=function(){
    alert(this.USRAPIURL('helloworld'));
    iwfRequest(this.USRAPIURL('helloworld'),this.iwfCallback,true,null);
    var ix=this.iRowIndexWithName('helloworld');
    if(ix>-1){
      return this.doc.rows[0].row[ix].name[0].getText();
    }else{
      return "";
    };
  };
};
 
