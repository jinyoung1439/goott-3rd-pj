package com.goott.pj3.travelinfo.controller;


import com.goott.pj3.common.util.paging.Criteria;
import com.goott.pj3.board.review.dto.ReviewDTO;
import com.goott.pj3.common.util.Criteria;
import com.goott.pj3.common.util.S3FileUploadService;
import com.goott.pj3.travelinfo.dto.TravelInfoDTO;
import com.goott.pj3.travelinfo.service.TravelInfoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/travelinfo/**")
public class TravelInfoController {

	@Autowired
	TravelInfoService travelInfoService;

	// AWS S3 파일 업로드
	@Autowired
	S3FileUploadService s3FileUploadService;

	/**
	 * 23.04.07. 여행지 정보 생성 페이지 호출
	 * @return
	 */
	@RequestMapping("create")
	public ModelAndView create(){
		ModelAndView mv = new ModelAndView();
		mv.setViewName("/travelinfo/travelinfo_create");
		return mv;
	}
	/**
	 * 조원재 23.04.7 여행지 정보 생성
	 * @param httpSession
	 * @param travelInfoDTO
	 * @param mv
	 * @return
	 */
	@PostMapping("create")
	public ModelAndView CreatePost(TravelInfoDTO travelInfoDTO, ModelAndView mv, HttpSession httpSession,
								   @RequestParam("file[]") List<MultipartFile> multipartFile){
		String user_id = (String) httpSession.getAttribute("user_id"); // 로그인한 유저 아이디 세션
		travelInfoDTO.setUser_id(user_id); // DTO에 유저 아이디 할당
		int travel_location_idx = this.travelInfoService.create(travelInfoDTO); // 생성된 게시글 idx
		ImgFileUpload(travelInfoDTO, multipartFile, travel_location_idx); // 이미지 파일 업로드 API
		if(travel_location_idx!=0){
			mv.setViewName("redirect:/review/detail/"+travel_location_idx);
		} else {
			mv.setViewName("review/review_create");
		}
		return mv;
	}

	/**
	 * 조원재 23.04.21 이미지 파일 업로드 API
	 * @param travelInfoDTO
	 * @param multipartFile
	 * @param review_idx
	 */
	private void ImgFileUpload(TravelInfoDTO travelInfoDTO, List<MultipartFile> multipartFile, int review_idx) {
		try {
			if(multipartFile !=null && !multipartFile.isEmpty()) { // 이미지 파일이 존재하는 경우
				List<String> imgList = s3FileUploadService.upload(multipartFile);
				travelInfoDTO.setCountry_img(imgList);
				travelInfoDTO.setTravel_location_idx(review_idx);
				this.travelInfoService.createImg(travelInfoDTO);
			} else { // 이미지 파일이 없는 경우
				travelInfoDTO.setTravel_location_idx(review_idx);
				this.travelInfoService.createImg(travelInfoDTO);
			}
		} catch (IOException e){
			throw new RuntimeException(e);
		}
	}

	/**
	 * 조원재 23.04.08 여행지 정보 디테일 페이지 호출
	 */
	@RequestMapping("detail/{travel_location_idx")
	public ModelAndView detail(@PathVariable int travel_location_idx,
							   TravelInfoDTO travelInfoDTO, ModelAndView mv){
		travelInfoDTO.setTravel_location_idx(travel_location_idx);
		TravelInfoDTO detail= this.travelInfoService.detail(travelInfoDTO);
		mv.addObject("data", detail);
		mv.setViewName("travelinfo/travelinfo_detail");
		return mv;
	}

	@GetMapping("update/{travel_location_idx}")
	public ModelAndView update(@PathVariable int travel_location_idx,
							   TravelInfoDTO travelInfoDTO, ModelAndView mv) {
		travelInfoDTO.setTravel_location_idx(travel_location_idx);
		TravelInfoDTO detail= this.travelInfoService.detail(travelInfoDTO); // 게시글 정보
		mv.addObject("data", detail); // 게시글 정보
		mv.setViewName("board/review/review_update");
		return mv;
	}

	@PostMapping("update/{review_idx}")
	public ModelAndView updatePost(@PathVariable int travel_location_idx,  TravelInfoDTO travelInfoDTO, ModelAndView mv,
								   @RequestParam("file[]") List<MultipartFile> multipartFile){
		travelInfoDTO.setTravel_location_idx(travel_location_idx);
		int succeessIdx = this.travelInfoService.update(travelInfoDTO); // 본문 내용 업데이트
		this.travelInfoService.deleteImg(travelInfoDTO); // 기존 img 삭제
		ImgFileUpdate(travel_location_idx, travelInfoDTO, mv, multipartFile, succeessIdx); // 이미지 파일 업데이트 API
		return mv;
	}

	private void ImgFileUpdate(int travel_location_idx, TravelInfoDTO travelInfoDTO, ModelAndView mv, List<MultipartFile> multipartFile, int succeessIdx) {
		try {
			if(multipartFile !=null) {
				List<String> imgList = s3FileUploadService.upload(multipartFile);
				travelInfoDTO.setCountry_img(imgList);
				travelInfoDTO.setTravel_location_idx(succeessIdx);
				this.travelInfoService.updateImg(travelInfoDTO);
			}
		} catch (IOException e){
			throw new RuntimeException(e);
		}
		if(succeessIdx !=0){
			mv.setViewName("redirect:/review/detail/"+ travel_location_idx);
		}
	}

//	/**
//	 * 조원재 23.04.08. 여행정보 수정 페이지 호출
//	 */
//	@RequestMapping("update")
//	public ModelAndView update(@RequestParam Map<String, Object> map) {
//		ModelAndView mv = new ModelAndView();
//		Map<String, Object> detailData = this.travelInfoService.detail(map);
//		mv.addObject("data", detailData);
//		mv.setViewName("travelinfo/travelinfo_update");
//		return mv;
//	}
//

//	/**
//	 * 조원재 23.04.08. 여행 정보 수정
//	 */
//	@RequestMapping(value = "update", method = RequestMethod.POST)
//	public ModelAndView updatePost(@RequestParam Map<String, Object> map){
//		ModelAndView mv = new ModelAndView();
//		boolean update = this.travelInfoService.update(map);
//		if(update){
//			String travel_location_idx = map.get("travel_location_idx").toString();
//			mv.setViewName("redirect:/travelinfo/detail?travel_location_idx="+travel_location_idx);
//		} else {
//			mv = this.update(map);
//		}
//		return mv;
//	}
//
//	/**
//	 * 조원재 23.04.08. 여행지 정보 삭제
//	 */
//	@RequestMapping("delete")
//	public ModelAndView delete(@RequestParam Map<String, Object> map){
//		ModelAndView mv = new ModelAndView();
//		boolean delete = this.travelInfoService.delete(map);
//		if (delete){
//			mv.setViewName("redirect:/travelinfo/list");
//		} else {
//			String travel_location_idx = map.get("travel_location_idx").toString();
//			mv.setViewName("redirect:/travelinfo/detail?travel_location_idx="+travel_location_idx);
//		}
//		return mv;
//	}
//
//	@RequestMapping("list")
//	public ModelAndView list(ModelAndView mv, Criteria cri){
//		mv.addObject("paging", travelInfoService.paging(cri));
//		mv.addObject("data", travelInfoService.list(cri));
//		mv.setViewName("/travelinfo/travelinfo_list");
//		return mv;
//	}
}
