import data from '@ohos.telephony.data'

export default class dietInfo{
  id:number
  userId:number
  type:number
  foodName : string=''
  totalCalorie :number=0
  count :number=0
  weight:string=''
  createTime:string
  isDeleted:number
}