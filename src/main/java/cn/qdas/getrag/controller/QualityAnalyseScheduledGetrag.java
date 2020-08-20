/**
 * 
 */
package cn.qdas.getrag.controller;

import cn.qdas.core.utils.ApplicationContextUtil;
import cn.qdas.getrag.bean.QualityBoardGetrag;
import cn.qdas.getrag.service.IGetragQualityBoardService;

import java.io.*;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * @author leo.Zhou 周钧 2019年11月6日
 */
public class QualityAnalyseScheduledGetrag {
	//@Scheduled(cron = "0 0 23 * * ?")
	// @Scheduled(cron="0/30 * * * * ?")
	public void doSynchronizedGetrag() {
		IGetragQualityBoardService iGetragQualityBoardService = (IGetragQualityBoardService) ApplicationContextUtil.getBean("getragQualityBoardServiceImpl");
		getLocalData(iGetragQualityBoardService);
	}
	public void getLocalData(IGetragQualityBoardService iGetragQualityBoardService){
		Map timeMap= getYesterdayTime();
		QualityBoardGetrag qualityBoard=new QualityBoardGetrag();
		qualityBoard.setStartTime(timeMap.get("startTime").toString());
		qualityBoard.setEndTime(timeMap.get("endTime").toString());
		List<Map> yesterDayList=iGetragQualityBoardService.getLocalEveryDayDataService(qualityBoard);
		//List saveList= new ArrayList<Map>();
		for(int i=0;i<yesterDayList.size();i++){
			Map saveMap=yesterDayList.get(i);
			List<Map> wvList= (List) saveMap.get("wvList");
			int nokCount=0;
			for(int j=0;j<wvList.size();j++){
				if(null!=wvList.get(j).get("MEMERKART")&&"1".equals(wvList.get(j).get("MEMERKART").toString())){
					if(wvList.get(j).get("WVWERT")!=null&&Float.parseFloat(wvList.get(j).get("WVWERT").toString().substring(wvList.get(j).get("WVWERT").toString().indexOf(".")-1))>0){
						nokCount += 1;
					}
				}else {
					if((wvList.get(j).get("MEUGW")!=null&&wvList.get(j).get("WVWERT")!=null&&
							Float.parseFloat(String.valueOf(wvList.get(j).get("WVWERT")))<Float.parseFloat(String.valueOf(wvList.get(j).get("MEUGW"))))||
							(wvList.get(j).get("MEOGW")!=null&&wvList.get(j).get("WVWERT")!=null&&
									Float.parseFloat(String.valueOf(wvList.get(j).get("WVWERT")))>Float.parseFloat(String.valueOf(wvList.get(j).get("MEOGW"))))) {
						nokCount += 1;
					}
				}
			}
			int okCount=wvList.size()-nokCount;
			float passRate=(float)okCount*100/wvList.size();
			DecimalFormat decimalFormat=new DecimalFormat(".00");
			saveMap.put("passRate",decimalFormat.format(passRate));
			saveMap.put("startTime", timeMap.get("startTime"));
		}

		//保存数据
		iGetragQualityBoardService.synchronizedLocalDataService(yesterDayList);
	}

	public static Map getYesterdayTime(){
		SimpleDateFormat startFormat=new SimpleDateFormat("yyyy-MM-dd 00:00:00");
		Date today=new Date();
		Calendar calendar=Calendar.getInstance();
		calendar.add(Calendar.DATE,-1);
		Date yesterdayDate=calendar.getTime();
		Map map=new HashMap();
		map.put("startTime",startFormat.format(yesterdayDate));
		map.put("endTime",startFormat.format(today));
//		map.put("startTime","2020-04-08 00:00:00");
//		map.put("endTime","2020-04-09 00:00:00");
		return map;
	}
	public static void doLog(String logStr) {
		Properties prop = new Properties();
		try {
			prop.load(QualityAnalyseScheduledGetrag.class.getResourceAsStream("/jdbc.properties"));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String filePath=prop.getProperty("cpkLogFile");

		Date now=new Date();
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String nowStr=sdf.format(new Date());
		File logFile=new File(filePath);
		if(!logFile.exists()) {
			try {
				logFile.createNewFile();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		FileOutputStream fos = null;
		OutputStreamWriter osw = null;
		BufferedWriter write = null;
		try {
			fos = new FileOutputStream(logFile,true);
			osw=new OutputStreamWriter(fos, "UTF-8");
			write=new BufferedWriter(osw);
			write.write(nowStr+"-----"+logStr+"\r\n");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}finally {
			try {
				write.close();
				osw.close();
				fos.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}


	}
}
