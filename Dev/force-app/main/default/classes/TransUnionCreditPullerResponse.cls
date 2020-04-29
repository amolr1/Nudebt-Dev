public class TransUnionCreditPullerResponse{
  public boolean success;
  public Integer status;  //200
  public cls_data data;
  public class cls_data {
    public String pullType;  //soft
    public cls_file file;
  }
  public  class cls_file {
    public cls_hx5 hx5;
  }
  public  class cls_hx5 {
    public String version;  //5.4
    public cls_bureau_xml_data bureau_xml_data;
  }
  public class cls_bureau_xml_data {
    public cls_tu_report tu_report;
  }
  public  class cls_tu_report {
    public cls_subject_segments subject_segments;
  }
  public class cls_subject_segments {
    public cls_trade_segments trade_segments;
    public cls_collection_segments collection_segments;
  }
  public class cls_trade_segments {
    public cls_trade[] trade;
  }
  public class cls_trade {
    public String account_number;  //111110299726
    public String balance;  //000000702
  }
  public class cls_collection_segments {
    public cls_collection collection;
  }
  public class cls_collection {
    public String account_number;  //11111IM3029130745
    public String current_balance;  //000000168
  }
  public static TransUnionCreditPullerResponse parse(String json){
    return (TransUnionCreditPullerResponse) System.JSON.deserialize(json, TransUnionCreditPullerResponse.class);
  }
}