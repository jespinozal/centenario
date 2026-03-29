import getCase from '@salesforce/apex/CEN_MilestonesByOwner_ctr.getCase';
import getHistory from '@salesforce/apex/CEN_MilestonesByOwner_ctr.getHistory';
import { LightningElement,api,track,wire } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import getHistory2 from '@salesforce/apex/CEN_MilestonesByOwner_ctr.getHistory2';


export default class CEN_MilestonesByOwner_lwc extends LightningElement {

    @api recordId;
    @track hs=[];
    @track hsx=[];

    convertDecimalHoursToHMS(decimalHours) {
        const hours = Math.floor(decimalHours); // Extract the whole hours
        const decimalMinutes = (decimalHours - hours) * 60; // Remaining minutes as a decimal
        const minutes = Math.floor(decimalMinutes); // Extract the whole minutes
        const decimalSeconds = (decimalMinutes - minutes) * 60; // Remaining seconds as a decimal
        const seconds = Math.round(decimalSeconds); // Round to the nearest whole second
      
        // Add leading zeros to hours, minutes, and seconds if needed
        const formattedHours = String(hours).padStart(2, '0'); 
        const formattedMinutes = String(minutes).padStart(2, '0');
        const formattedSeconds = String(seconds).padStart(2, '0');
      
        return `${formattedHours}:${formattedMinutes}:${formattedSeconds}`; // Combine and return
    }


    findNextOwner(osList,dt,c){
        console.log('osList',osList);
        let rt = undefined;
        for(let i=0;i<osList.length;i++){
            
            const os = osList[i];
            const ndt = new Date(dt);
            const odt = new Date(os.CreatedDate); 
            console.log(odt,ndt,odt<ndt);
            if(odt<ndt){
                console.log("osx",os);
                rt = os;
                return os;
            }
            rt = os;
        }

        console.log('rt',rt);

        return {NewValue:rt?rt.OldValue:c.Owner.Name,OldValue:rt?rt.OldValue:c.Owner.Name};
    }

    get reactiveRecordId() {
        return this.recordId;
    }

    @wire(getRecord, { recordId: '$reactiveRecordId', fields: ['Id'] })
    wiredRecord(result) {

        this.refreshData();

    }

    processData(hsList,c){
        console.log('hsList',hsList);
        //this.hs = hsList.slice(0);
        const _hs = [];
        const ssList = hsList.filter((o)=>o.Field=='Status');
        const osList = hsList.filter((o)=>o.Field=='Owner' && o.DataType == 'Text');
        console.log('ssList',ssList);
        for (let i = 0;i<ssList.length;i++){
            
            const hs=ssList[i];
            
            
            let ps=ssList[i+1];
            ps=ps?ps:{CreatedDate:c.CreatedDate};
            const cTime = new Date(hs.CreatedDate); 
            const pTime = new Date(ps.CreatedDate);
            console.log('time',cTime,pTime);
            const differenceInMilliseconds = cTime.getTime() - pTime.getTime();
            const differenceInHours = differenceInMilliseconds / (1000 * 60 * 60); 
            const owner = this.findNextOwner(osList,hs.CreatedDate,c);
            console.log('hs',hs);
            _hs.push({status:hs.OldValue,tm: this.convertDecimalHoursToHMS(differenceInHours),owner:owner.NewValue,ownerOld:owner.OldValue,bt:pTime.toLocaleString(),et:cTime.toLocaleString()});
        }
        console.log("_hs",_hs);

        this.hs = _hs.slice(0);
        this.hsx=[].slice(0);
        this.hs.forEach((l)=>{
            this.hsx.push([{k:"Estado",v:l["status"]},{k:"Inicio",v:l["bt"]},{k:"Fin",v:l["et"]},{k:"Tiempo Transcurrido",v:l["tm"]},{k:"Owner Origen",v:l["ownerOld"]},{k:"Owner Nuevo",v:l["owner"]}])
            console.log("l",JSON.stringify(l));
        });

        console.log("hsx",JSON.stringify(this.hsx));
    }

    processData2(hsList,c){
        let et=undefined;
        this.hsx=[].slice(0);
        for(let i=0;i<hsList.length;i++){
            const l= hsList[i];
            const j=hsList[i+1]?hsList[i+1]:{"CreatedDate":c.CreatedDate};

            const cTime = new Date(l.CreatedDate); 
            const pTime = new Date(j.CreatedDate);

            const differenceInMilliseconds = cTime.getTime() - pTime.getTime();
            const differenceInHours = differenceInMilliseconds / (1000 * 60 * 60);

            this.hsx.push(
                [
                    {k:'Estado',v:l["CEN_Status_Old__c"]},
                    
                    {k:"Fin",v:new Date(l["CreatedDate"]).toLocaleString()},
                    {k:"Inicio",v:new Date(j["CreatedDate"]).toLocaleString()},
                    {k:"Tiempo Transcurrido",v:this.convertDecimalHoursToHMS(differenceInHours)},
                //    {k:"Owner Origen",v:l["CEN_Owner_Old__c"]},
                    {k:"Owner",v:l["CEN_Owner_Old__c"]?l["CEN_Owner_Old__c"]:"Cola de Administradores de Casos"}
                ])
        };
    }

    async refreshData(){
        console.log(this.recordId);
        const hsList = await getHistory({caseId:this.recordId});
        const hs2List = await getHistory2({caseId:this.recordId});
        console.log('hs2List',hs2List);
        const c = await getCase({caseId:this.recordId});
        console.log('ccc',c);


        //this.processData(hsList,c);
        this.processData2(hs2List,c);
        
    }

    async connectedCallback(){
                    this.refreshData();
        
    }

}