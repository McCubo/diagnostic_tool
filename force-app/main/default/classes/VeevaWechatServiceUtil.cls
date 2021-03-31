public class VeevaWechatServiceUtil {
    public static Map<String,String> getPostHeaders(String ts, String orgId){
        Map<String,String> headers=new Map<String,String>();
        String token = generateToken(ts, orgId);
        headers.put('Content-Type', 'application/json; charset=UTF-8');
        headers.put('token', token);
        return headers;
    }
    private static String generateToken(String ts, String orgId){
        String salt = orgId+ts;
        String secret = orgId.substring(1,orgId.length()-1);
        Blob hmacData = Crypto.generateMac('HmacSHA256', Blob.valueOf(salt), Blob.valueOf(secret));
        return EncodingUtil.base64Encode(hmacData);
    }
}