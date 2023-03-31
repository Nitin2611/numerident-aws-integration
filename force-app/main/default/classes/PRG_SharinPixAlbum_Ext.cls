global without sharing class PRG_SharinPixAlbum_Ext {
    public String AlbumId {get;set;}
    public String url { get; set; }
    public boolean Authorized { get; set; }
    public String currentRecordId {get;set;}
    public case Cs {get;set;}
    
    global PRG_SharinPixAlbum_Ext(){
        Authorized = false;
        AlbumId = Apexpages.currentPage().getParameters().get('CID');
        //string OID = Apexpages.currentPage().getParameters().get('OID');
        string H = Apexpages.currentPage().getParameters().get('H');
        List<Case> Css = [Select Id,CaseNumber,Dossier__r.Name,Dossier__r.Patient__c,Status,Dossier__r.Account.Name,Dossier__r.Praticien__r.FirstName,
                            Dossier__r.Praticien__r.LastName,CATEGORY_EN_FRANCAIS__c from Case 
                          where Id=:AlbumId and hash__c=:H and hash__c!=null]; 
        if(Css.size()==1){
            Authorized = true;
            currentRecordId = Css[0].Id;
            Cs = Css[0];
/*          Map<String, Object> claims = new Map<String, Object> {
                'abilities' => new Map<String, Object> {
                    albumId => new Map<String, Object> {
                        'Access'  => new Map<String, Object> {
                            'see' => true,
                            'image_list' => true,
                            'image_upload' => false,
                            'image_delete' => false,
                            'image_crop' => false,
                            'image_rotate' => false,
                            'image_annotate' => false 
                        }
                    }
                }
            };
            url = 'https://app.sharinpix.com/pagelayout/' + (string)Cs.Id + '?token=' + sharinpix.Client.getInstance().token(claims);   */
        }
    }
    @RemoteAction
    global static String generateToken(String recordId){
        String token;
        
        token = sharinpix.Client.getInstance().token(
                new Map<String, Object> {
                    'album_id' => recordId,
                    'exp' => 0,
                    'path' => '/pagelayout/' + recordId,
                    'abilities' => new Map<String, Object> {
                        recordId => new Map<String, Object> {
                            'Access' => new Map<String, Boolean> {
                                'see' => true,
                                'image_list' => true,
                                'image_upload' => false,
                                'image_delete' => false
                            }
                        }
                    }
                }
            );
        return token;
    }   
}