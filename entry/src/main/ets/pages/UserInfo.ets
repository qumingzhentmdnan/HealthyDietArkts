import picker from '@ohos.file.picker';
import common from '@ohos.app.ability.common';
import updatePasswordPopup from '../view/updatePasswordPopup'
import PreferenceUtil from '../common/utils/PreferenceUtil'
import router from '@ohos.router';

@Component
@Preview
export default struct  UserInfo{

  @State uri:string=''
  @State IsUpdateHeadPicture:boolean=true
  async select() {
    try {
      let PhotoSelectOptions = new picker.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.maxSelectNumber = 5;
      let photoPicker = new picker.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        this.uri=PhotoSelectResult.photoUris[0]
        PreferenceUtil.putPreferenceValue('headPicture',this.uri)
        console.log('@@@@@@@@@'+this.uri)
        this.IsUpdateHeadPicture=false
        console.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
      }).catch((err) => {
        console.error('PhotoViewPicker.select failed with err: ' + err);
      });
    } catch (err) {
      console.error('PhotoViewPicker failed with err: ' + err);
    }
  }

  //获取context对象
  context = getContext(this) as common.UIAbilityContext
  //获取弹窗对象
  dialogController:CustomDialogController=new CustomDialogController({
    builder: updatePasswordPopup({})
  })

async aboutToAppear(){
  let res=await PreferenceUtil.getPreferenceValue('headPicture','')
  this.uri=res.toString()
  if(this.uri){
    this.IsUpdateHeadPicture=false
  }
}

  build() {
    Column() {
      Stack(){
        Image(this.IsUpdateHeadPicture?$r('app.media.default_head_picture'):this.uri)
          .width('50%')
          .height('30%')
          .borderRadius(100)
          .borderWidth(5)
          .alignSelf(ItemAlign.Center)
          .margin({top:'10%'})

        Button('修改头像')
          .margin({top:'45%'})
          .backgroundColor(Color.Gray)
          .onClick(async ()=>{
            await this.select()
          })
      }.margin({bottom:50})

      Row(){
        Text('手机号')
          .fontSize(25)
          .margin({left:'10%',right:'10%'})
        Text('18250956975')
          .fontSize(20)
          .fontWeight(FontWeight.Lighter)
      }
      .width('90%')
      .margin({bottom:30})

      Row({space:10}){
        Text('密码')
          .alignSelf(ItemAlign.Center)
          .fontSize(25)
        Text('*********')
          .fontSize(20)
          .fontWeight(FontWeight.Lighter)
        Button('修改密码')
          .backgroundColor(Color.Gray)
          .width('20%')
          .fontSize(15)
          .padding({bottom:1,top:1,left:1,right:1})
          .onClick(()=>{
            this.dialogController.open()
          })
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({bottom:80})

      Button('退出登录')
        .width('60%')
        .backgroundColor(Color.Red)
        .onClick(()=>{
          router.clear()
          router.replaceUrl({
            url:'pages/loginPage'
          })
        })
    }.width('100%') .height('100%')
  }
}