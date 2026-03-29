public class WordToUpperCase {
public static String ConvertWord(String word){
    
        String editWord = '';
        word = word.toLowerCase();
        word = word.capitalize();
       
        if (word.contains(' ')){
            String[] cadena = word.split('\\s');
            for(String w:cadena){
                editWord = editWord + ' ' + w.capitalize();
            }
        } else{
            editWord = word.capitalize();
        }
        system.debug(editWord);
        return editWord;
    }
    
public static String ucFirst(String word2) {
    word2 = word2.toLowerCase();
    if (word2 == null || word2 == '') {
        return word2;            
    } else {
        return word2.substring(0, 1).toUpperCase() + word2.substring(1); 
    }
}
}