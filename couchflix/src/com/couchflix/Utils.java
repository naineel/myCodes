package com.couchflix;

import java.util.Calendar;
import java.util.Date;

public class Utils {
	
	//dateString format: YYYY-MM-DD
	public static Date stringToDate(String dateString) {
		Calendar calendar = Calendar.getInstance();
		calendar.set(Integer.parseInt(dateString.split("-")[0]), Integer.parseInt(dateString.split("-")[1]) - 1, Integer.parseInt(dateString.split("-")[2]));
		Date date = new Date();
		date.setTime(calendar.getTimeInMillis());
		return date;
	}
	
	public static String dateToString(Date date) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		String dateString = calendar.get(Calendar.YEAR) + "-" + (calendar.get(Calendar.MONTH)+1) + "-" + calendar.get(Calendar.DAY_OF_MONTH);
		return dateString;
	}

}
