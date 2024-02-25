import router from '@ohos.router'
import check from '../function/infoCheck'
import simplePopup from  '../view/simplePopup'
import axios from '@ohos/axios'
import PreferenceUtil from '../common/utils/PreferenceUtil'
@CustomDialog
export default struct updatePasswordPopup {
  controller:CustomDialogController
  @State newPassword:string=''
  @State oldPassword:string=''
  @State message:string='请输入6-16数字字母组合新密码'
  url:string='http://192.168.73.99:8080'

  checkPassword():boolean{
    if(!this.newPassword||!check.checkPassword(this.newPassword)){
      this.newPassword=''
      this.message='密码格式错误！请输入6-16位字母数组组合'
      return false
    }
    return true
  }



  async updatePassword(){
    let token =await PreferenceUtil.getPreferenceValue('token','') as string
    try {
      let res=await axios({
        url:this.url+'/user/updatePasswordByOldPassword',
        method:"put",
        data:{
          oldPassword:this.oldPassword,
          password:this.newPassword
        },
        headers:{
          token:token
        }
      })
      if(res.data.code!=20000){
        this.newPassword=''
        this.message=res.data.message
        return false
      }
      return true
    }catch (Exception){
      console.log(Exception)
    }
  }

  build() {
    Column({space:15}){
      TextInput({placeholder:'请输入原先密码',text:this.oldPassword})
        .type(InputType.Password)
        .onChange(value=>{
          this.oldPassword=value
        })
     Column(){
       TextInput({placeholder:this.message,text:this.newPassword})
         .type(InputType.Password)
         .onChange(value=>{
           this.newPassword=value
         })
       Text('忘记了？找回密码')
         .width('85%')
         .fontSize(10)
         .fontColor(Color.Blue)
         .margin({top:10})
         .onClick(()=>{
           router.pushUrl({
             url:'pages/registerPage',
             params:{
               isRegister:false
             }
           })
         })
     }
      Row({space:30}){
        Button('确认')
          .backgroundColor($r('app.color.green'))
          .onClick(async ()=>{
            if(!this.checkPassword())
              return
            let res=await this.updatePassword()
            if(res)
              this.controller.close()
          })
        Button('取消')
          .backgroundColor($r('app.color.gray'))
          .onClick(()=>{
            this.controller.close()
          })
      }
    }
    .width('80%')
    .padding(10)
  }
}