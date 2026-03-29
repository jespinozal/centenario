public class CEN_cls_XMLHelper {
    /*
     * scaped characters for xml string
	*/
    public static String getString(String text){
        if(String.isNotBlank(text)){
            text = text.replace('&', '&amp;');
            text = text.replace('<', '&lt;');
            text = text.replace('>', '&gt;');
            text = text.replace('"', '&quot;');
            text = text.replace('\'', '&apos;');
            return text;
        }else{
            return '';
        }
    }
}