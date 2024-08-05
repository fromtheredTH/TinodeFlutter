  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("채팅방"),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          SizedBox(
              // SizedBox 대신 Container를 사용 가능
              width: double.infinity,
              height: 250,
              child: Column(
                children: [
                  Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black)),
                    padding: const EdgeInsets.only(
                        left: 20, top: 12, bottom: 12, right: 10),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: inputController,
                          cursorColor: Colors.black,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                          onEditingComplete: () {},
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.done,
                          maxLength: 50,
                          decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.zero,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              hintText: 'input text...',
                              isDense: true,
                              hintStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              border: InputBorder.none),
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                      ),
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 120,
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            if (inputController.value.text != "") {
                              addMsg(inputController.value.text);
                              inputController.clear();
                            } else
                              showToast("내용을 입력하세요");
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Text('text 전송'),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 100,
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            deleteTopic();
                          },
                          child: Text('방 삭제'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            color: Colors.black,
                            width: 30,
                            height: 30,
                          ),
                          fileButtonWidget(),
                        ],
                      ),
                      AppText(
                        text: '사진/동영상 선택',
                        fontSize: 12,
                      ),
                    ],
                  ),
                  SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 200,
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            Get.to(SettingChatExpirationeScreen(tinode: tinode_global, roomTopic: roomTopic));
                          },
                          child: Text('자동삭제조정 설정'),
                        ),
                      ),
               
                      SizedBox(height: 10,),
                      if(roomTopic.isP2P())
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [ 
                           SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 100,
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            requestVoiceCall();
                          },
                          child: Text('음성통화'),
                        ),
                      ),
                         SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 100,
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            requestVideoCall();
                          },
                          child: Text('영상통화'),
                        ),
                      ),
                      ],),
                 
                ],
              )),
         
          Expanded(
            child: ListView.builder(
                cacheExtent: double.infinity,
                shrinkWrap: false,
                padding: const EdgeInsets.all(10),
                controller: mainController,
                itemCount: msgList.length,
                reverse: true,
                physics: physics,
                itemBuilder: (BuildContext context, int index) {
                  return AutoScrollTag(
                    key: ValueKey(index),
                    controller: mainController,
                    index: index,
                    child: selectMsgWidget(msgList[index], index),
                  );
                }),
          ),
        ]),
      ),
    );
  }
}
