package com.goott.pj3.chat.controller;

import com.goott.pj3.chat.dto.ChatMessageDTO;
import com.goott.pj3.chat.repo.ChatRoomRepository;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

//2023.04.28 길영준
// 2023.05.01 길영준
// 실시간 알람 추가, 메세지 로그 저장 구현
@Controller
public class StompChatController {
    private final SimpMessagingTemplate template; //특정 Broker로 메세지를 전달
    private final ChatRoomRepository repository;


    public StompChatController(SimpMessagingTemplate template, ChatRoomRepository repository) {
        this.template = template;
        this.repository = repository;
    }

    //Client가 SEND할 수 있는 경로
    //stompConfig에서 설정한 applicationDestinationPrefixes와 @MessageMapping 경로가 병합됨
    //"/pub/chat/enter"
    @MessageMapping(value = "/chat/enter")
    public void enter(ChatMessageDTO chatMessageDTO) {
        chatMessageDTO.setMsg_content(chatMessageDTO.getSend_id() + "님이 채팅방에 참여하였습니다.");
        template.convertAndSend("/sub/chat/room/" + chatMessageDTO.getMsg_idx(), chatMessageDTO);
    }

    @MessageMapping(value = "/chat/message") //DTO = roomid, message, 보낸사람, 받는사람
    public void message(ChatMessageDTO chatMessageDTO) {
        template.convertAndSend("/sub/chat/room/" + chatMessageDTO.getMsg_idx(), chatMessageDTO);
        repository.saveMessageLog(chatMessageDTO);  //로그 DB에 저장
        //실시간 알람
        String alarmDestination = "/sub/chat/alarm/" + chatMessageDTO.getReceive_id();
        String alarmMessage = chatMessageDTO.getSend_id() + "님의 새로운 메세지";
        template.convertAndSend(alarmDestination, alarmMessage);
    }
}
