import relationalStore from '@ohos.data.relationalStore';
import dialogInfo from '../bean/dialogInfo'
import dietType from '../bean/dietType'
import dietInfo from '../bean/dietInfo'
import foodInfo from '../bean/foodInfo'

class sqlUtil{
  private rdbStore:relationalStore.RdbStore
   init(context){
    const config={
      name:'HealthyDiet',
      securityLevel:relationalStore.SecurityLevel.S1
    }
    //创建聊天记录表
    const chatSql= 'CREATE TABLE IF NOT EXISTS audio (id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER DEFAULT 0, file_path TEXT,text TEXT,userRequest TEXT);'
    //饮食类型表
    const typeSql='CREATE TABLE IF NOT EXISTS diet_type (id INTEGER PRIMARY KEY,type_name TEXT,suggestLowest INTEGER,suggestHighest INTEGER,is_deleted INTEGER);'
    //饮食详细信息表
    const dietInfoSql='CREATE TABLE diet_info (id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER,type INTEGER,food_name TEXT,total_calorie REAL,count INTEGER,weight TEXT,create_time TEXT,is_deleted INTEGER DEFAULT 0);'
    //食物详细信息表
    const foodInfo='CREATE TABLE food_info (id INTEGER PRIMARY KEY AUTOINCREMENT,food_name TEXT,weight TEXT,calorie REAL,is_deleted INTEGER DEFAULT 0);'

     relationalStore.getRdbStore(context,config,(err,rdbStore)=>{
       if(err)
         console.log(err.message)
       console.log('execute');
       rdbStore.executeSql(dietInfoSql)
       rdbStore.executeSql(chatSql)
       rdbStore.executeSql(typeSql)
       rdbStore.executeSql(foodInfo)
       this.rdbStore=rdbStore
     })
   };

  //插入聊天记录
   async setAudio(userId:number,filePath:string,text:string,userRequest:string){
       const audioInfo={user_id:userId,file_path:filePath,text:text,userRequest:userRequest}
       let res= this.rdbStore.insert('audio',audioInfo)
         .then(()=>{
           console.log('insert:'+res)
         })
         .catch((err)=>{
         console.log(err)
       })
  }

  //查询聊天记录
  async queryAudio(){
    let predicates=new relationalStore.RdbPredicates('audio')
    let res=await this.rdbStore.query(predicates)
    let audioList:dialogInfo[]=[]
    while(!res.isAtLastRow){
      res.goToNextRow()
      let id=res.getLong(res.getColumnIndex('id'))
      let user_id=res.getLong(res.getColumnIndex('user_id'))
      let file_path=res.getString(res.getColumnIndex('file_path'))
      let text=res.getString(res.getColumnIndex('text'))
      let userRequest=res.getString(res.getColumnIndex('userRequest'))
      console.log(file_path)
      audioList.push({id,user_id,file_path,text,userRequest})
    }
    return audioList
  }

  //插入饮食类型
  setDietType(List:dietType[]){
    for (let i = 0; i < List.length; i++) {
      let type={type_name:List[i].typeName,suggestLowest:List[i].suggestLowest,suggestHighest:List[i].suggestHighest,is_deleted:List[i].isDeleted}
      this.rdbStore.insert('diet_type',type).then(value=>{
        //console.log(value.toString())
      }).catch(reason=>{
        console.log(reason)
      })
    }
  }

  //查询饮食类型
  async getAllDietType(){
    let predicates=new relationalStore.RdbPredicates('diet_type').equalTo('is_deleted',0)
    let res=await this.rdbStore.query(predicates)
    let dietTypeList:dietType[]=[]
    while(!res.isAtLastRow){
      res.goToNextRow()
      let id=res.getLong(res.getColumnIndex('id'))
      let typeName=res.getString(res.getColumnIndex('type_name'))
      let suggestLowest=res.getDouble(res.getColumnIndex('suggestLowest'))
      let suggestHighest=res.getDouble(res.getColumnIndex('suggestHighest'))
      dietTypeList.push({id,typeName,suggestLowest,suggestHighest,isDeleted:0})
    }
    return dietTypeList
  }

  //删除饮食类型
  async deletedDietType(id:number){
    let sql=`UPDATE diet_type SET is_deleted = 1 WHERE id=${id}`
    let res=await this.rdbStore.executeSql(sql)
    return res
  }


  //插入饮食详细信息，以List
  async setDietInfoList(List:dietInfo[]){
    console.log('插入饮食信息条数'+List.length)
    for (let i = 0; i < List.length; i++){
      try {
        let date=new Date(List[i].createTime)
        let dateString = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
        let info={id:List[i].id,user_id:List[i].userId, type:List[i].type, food_name : List[i].foodName, total_calorie :List[i].totalCalorie, count :List[i].count,weight:List[i].weight, create_time:dateString, is_deleted:List[i].isDeleted}
        console.log(info.type+'  '+info.create_time);
        await this.rdbStore.insert('diet_info',info)
      }catch (Exception){
        console.log(Exception)
      }
    }
  }

  //插入一条饮食详细信息
  setDietInfoByOne(dietInfo:dietInfo){
    let info={user_id:dietInfo.userId, type:dietInfo.type, food_name : dietInfo.foodName, total_calorie :dietInfo.totalCalorie, weight:dietInfo.weight,count :dietInfo.count, create_time:dietInfo.createTime, is_deleted:dietInfo.isDeleted}
    this.rdbStore.insert('diet_info',info).then(value=>{
      console.log(value.toString())
    }).catch(reason=>{
      console.log(reason)
    })
  }

  //根据日期和时间得到饮食信息
  async getDietInfoByTypeAndDate(type:number,date:Date){
    let dateString = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
    let sql=`SELECT * FROM diet_info WHERE type = ${type}  AND create_time='${dateString}' AND is_deleted =0`
    try {
      let res=await this.rdbStore.querySql(sql)
      let dietInfoList:dietInfo[]=[]
      console.log(type+dateString+'')
      console.log('根据日期查询条数'+res.rowCount.toString())
      while(!res.isAtLastRow){
        res.goToNextRow()
        let id=res.getLong(res.getColumnIndex('id'))
        let userId=res.getLong(res.getColumnIndex('user_id'))
        let foodName=res.getString(res.getColumnIndex('food_name'))
        let weight=res.getString(res.getColumnIndex('weight'))
        let totalCalorie=res.getLong(res.getColumnIndex('total_calorie'))
        let count=res.getLong(res.getColumnIndex('count'))
        dietInfoList.push({id,userId,type:0,foodName,totalCalorie,weight,count,createTime:null,isDeleted:0})
      }
      return dietInfoList
    }catch (Exception){
      console.log(Exception)
    }
  }

  //删除饮食信息
  async deletedDietInfo(id:number){
    let predicates=new relationalStore.RdbPredicates('diet_info').equalTo('id',id)
    let res=await this.rdbStore.delete(predicates)
    return res
  }

  //得到总的卡路里数
  async getTotalCalorie(date:Date){
    let dateString = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
    let sql=`SELECT total_calorie FROM diet_info WHERE create_time='${dateString}' AND is_deleted=0;`
    let res=await this.rdbStore.querySql(sql)
    let sum=0
    while(!res.isAtLastRow){
      res.goToNextRow()
      sum+=res.getLong(res.getColumnIndex('total_calorie'))
    }
    return sum
  }

  //得到每一餐的卡路里数
  async getTotalCalorieByType(date:Date,type:number){
    let dateString = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
    let sql=`SELECT total_calorie FROM diet_info WHERE create_time='${dateString}' AND type=${type} AND is_deleted=0;`
    console.log(dateString+type)
    let res=await this.rdbStore.querySql(sql)
    let sum=0
    while(!res.isAtLastRow){
      res.goToNextRow()
      sum+=res.getLong(res.getColumnIndex('total_calorie'))
    }
    return sum
  }

  //插入食物信息表
  async setFoodInfo(List:foodInfo[]){
    for (let i = 0; i < List.length; i++) {
      let foodInfo={id:List[i].id,food_name:List[i].foodName,weight:List[i].weight,calorie:List[i].calorie}
      await this.rdbStore.insert('food_info',foodInfo).then(value=>{
        //console.log(value.toString())
      }).catch(reason=>{
        console.log(reason)
      })
    }
  }

  async getFoodInfoByKey(key:string){
    let query=new relationalStore.RdbPredicates('food_info').equalTo('is_deleted',0).like('food_name',key)
    let res=await this.rdbStore.query(query)
    let foodInfo:foodInfo[]=[]
    while(!res.isAtLastRow){
      res.goToNextRow()
      let id=res.getLong(res.getColumnIndex('id'))
      let foodName=res.getString(res.getColumnIndex('food_name'))
      let weight=res.getString(res.getColumnIndex('weight'))
      let calorie=res.getLong(res.getColumnIndex('calorie'))
      foodInfo.push({id,foodName,weight,calorie})
    }
    return foodInfo;
  }
}

let sql=new sqlUtil();
export default sql;
