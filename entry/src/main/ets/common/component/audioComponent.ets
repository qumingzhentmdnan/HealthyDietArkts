import media from '@ohos.multimedia.media';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import request from '@ohos.request';
import sql from '../utils/sqlUtil'
import PreferenceUtil from '../utils/PreferenceUtil';

@Component
export default  struct audioComponent {
  @State isStart:boolean=false
  @State totalLength:number=0
  @State currentLength:number=0
  @State isDownLoad:boolean=false
  @Prop @Watch('download') text:string
  file_path:string
  user_id:number=0
  userRequest:string
  public avPlayer:media.AVPlayer;
  private count: number = 0;


  async download(){
    let token =await PreferenceUtil.getPreferenceValue('token','') as string
    let context = getContext(this) as common.UIAbilityContext
    if(await fs.access(this.file_path)){
      let stat=await fs.stat(this.file_path)
      if(stat.size<100)
        await fs.unlink(this.file_path)
    }

    try {
      request.downloadFile(context, { url: `http://192.168.73.99:8080/chat/getVoice?id=${this.user_id}&message=${this.text}`,
        header:{
          token:token
        }
        ,filePath:this.file_path})
        .then((data) => {
          data.on("progress",(receivedSize, totalSize) => {
            console.info("download receivedSize:" + receivedSize + " totalSize:" + totalSize);
          })
          data.on("complete",async ()=>{
            await sql.setAudio(this.user_id,this.file_path,this.text,this.userRequest)
            console.log("保存成功")
            console.log("下载完成")
          })
          data.on("fail",(err)=>{
            this.download()
          })
        }).catch((err) => {
        console.error('Failed to request the download. Cause: ' + JSON.stringify(err));
      })
    } catch (err) {
      console.log(this.file_path)
      this.avPlayerUrlDemo(this.file_path)
      console.error('err.code : ' + err.code + ', err.message : ' + err.message);
    }
  }


  // 注册avplayer回调函数
  setAVPlayerCallback() {
    // seek操作结果回调函数
    this.avPlayer.on('seekDone', (seekDoneTime) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用reset接口触发重置流程
    this.avPlayer.on('error', (err) => {
      console.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset(); // 调用reset重置资源，触发idle状态
    })

    this.avPlayer.on('timeUpdate', (time:number) => {
      this.currentLength=Math.floor(time)
    })

    this.avPlayer.on('durationUpdate', (duration) => {
      this.totalLength=Math.floor(duration)
    })

    this.avPlayer.on('audioInterrupt',()=>{
      this.isStart=false
    })
    // 状态机变化回调函数
    this.avPlayer.on('stateChange', async (state, reason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          console.info('AVPlayer state idle called.');
          this.avPlayer.release(); // 调用release接口销毁实例对象
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          console.info('AVPlayerstate initialized called.');
          this.avPlayer.prepare().then(() => {
            console.info('AVPlayer prepare succeeded.');
          }, (err) => {
            console.error(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          this.avPlayer.play(); // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          break;
        case 'completed': // 播放结束后触发该状态机上报
          this.isStart=false
          this.avPlayer.pause(); //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          break;
        case 'released':
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    })
  }


  // 以下demo为使用fs文件系统打开沙箱地址获取媒体文件地址并通过url属性进行播放示例
  async avPlayerUrlDemo(path) {
    // 创建avPlayer实例对象
    this.avPlayer = await media.createAVPlayer();
    // 创建状态机变化回调函数
    this.setAVPlayerCallback();
    let fdPath = 'fd://';
    // 打开相应的资源文件地址获取fd，并为url赋值触发initialized状态机上报
    let file:fs.File = await fs.open(path);
    fdPath = fdPath + '' + file.fd;
    this.avPlayer.url = fdPath;
  }

  // 以下demo为使用资源管理接口获取打包在HAP内的媒体资源文件并通过fdSrc属性进行播放示例
  async avPlayerFdSrcDemo() {
    // 创建avPlayer实例对象
    this.avPlayer = await media.createAVPlayer();
    // 创建状态机变化回调函数
    this.setAVPlayerCallback();
    // 通过UIAbilityContext的resourceManager成员的getRawFd接口获取媒体资源播放地址
    // 返回类型为{fd,offset,length},fd为HAP包fd地址，offset为媒体资源偏移量，length为播放长度
    let context = getContext(this) as common.UIAbilityContext;
    let fileDescriptor = await context.resourceManager.getRawFd('01.mp3');
    // 为fdSrc赋值触发initialized状态机上报
    this.avPlayer.fdSrc = fileDescriptor;
  }


  build() {
    Column(){
      Row(){
        Image($r('app.media.start'))
          .width('7%')
          .interpolation(10)
          .visibility(this.isStart?Visibility.Visible:Visibility.None)
          .onClick(()=>{
            if(!this.avPlayer){
              this.isStart=false
              this.avPlayerUrlDemo(this.file_path)
            }else{
              this.isStart=false
              this.avPlayer.pause()
            }
          }).visibility(this.isStart?Visibility.Visible:Visibility.Hidden)

        Image($r('app.media.pause'))
          .width('7%')
          .interpolation(10)
          .onClick(()=>{
            if(!this.avPlayer){
              this.isStart=true
              this.avPlayerUrlDemo(this.file_path)
            }else{
              this.isStart=true
              this.avPlayer.play()
            }
          }).visibility(this.isStart?Visibility.None:Visibility.Visible)

        Slider({step:1,value:Math.floor(this.currentLength/1000),min:0,max:Math.floor(this.totalLength/1000)})
          .width('50%')
          .blockColor(Color.Gray)
          .onChange((value)=>{
            if(!this.avPlayer){
              this.avPlayerUrlDemo(this.file_path)
            }else{
              this.avPlayer.seek(value*1000)
            }
          })

        Text(Math.floor(this.currentLength/1000)+" / "+Math.floor(this.totalLength/1000))
          .width('15%')
          .fontSize(10)
      }
    }
  }
}