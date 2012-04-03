//
//  G4CardSize.m
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4CardSize.h"

static float card_width[] = {66.0f, 138.0f};
static float card_height[] = {88.0f, 184.0f};
static char card_font_size[] = {18, 46};
static float card_edge_width[] = {20.0f, 44.0f};
static float card_type_width[] = {16.0f, 36.0f};
static float card_number_width[] = {10.0f, 24.0f};
static float card_number_edge[] = {2.0f, 4.0f};
static float card_corner_radius[] = {6.0f, 10.0f};
static float card_border_width[] = {0.5f, 1.0f};
static float edge_space[] = {5.0f, 15.0f};
static float card_max_show_width[] = {30.0f, 60.0f};
static float device_view_width[] = {480.0f, 1024.0f};
static float device_view_height[] = {300.0f, 748.0f};
static float card_min_show_width[] = {12.0f, 28.0f};
static float line_width[] = {0.8f, 2.0f};

static float waiting_view_font_size[] = {15.0f, 40.0f};
static float waiting_view_width[] = {350.0f, 720.0f};
static float waiting_view_info_x[] = {20.0f, 40.0f};
static float waiting_view_player_name_height[] = {40.0f, 100.0f};
static float waiting_view_info_edge[] = {5.0f, 20.0f};
static float waiting_view_player_name_y[] = {30.0f, 80.0f};
static float waiting_view_image_height[] = {20.0f, 40.0f};
static float ad_view_height[] = {60.0f, 120.0f};

static float player_image_size[] = {50.0f, 100.0f};
static float player_board_info_size[] = {80.0f, 160.0f};
static float player_board_font_size[] = {15.0f, 30.0f};

static float watcher_size[] = {40.0f, 80.0f};
static float card_select_up[] = {15.0f, 30.0f};

static float float_info_width[] = {60.0f, 160.0f};
static float float_info_height[] = {40.0f, 100.0f};

static float float_info_font_size[] = {16.0f, 40.0f};

static float cmd_pannel_width[] = {280.0f, 560.0f};
static float cmd_pannel_height[] = {30.0f, 51.0f};
static float cmd_button_width[] = {50.0f, 110.0f};

static float mode_image_size[] = {60.0f, 140.0f};
static float game_center_image_x[] = {340.0f, 700.0f};
static float lan_image_x[] = {60.0f, 130.0f};
static float mode_image_y[] = {150.0f, 350.0f};

static float result_name_width[] = {100.0f, 200.0f};
static float result_round_score_width[] = {50.0f, 140.0f};
static float result_total_score_width[] = {80.0f, 160.0f};
static float result_cell_height[] = {30.0f, 60.0f};
static float result_font_size[] = {16.0f, 32.0f};

static float card_deal_max_animation_duration = 0.2f;

static char device_type;
static float max_distance;

@implementation G4CardSize

+(void)setDeviceType:(char)type
{
    device_type = type;
}

+(float)cardCorner
{
    return card_corner_radius[device_type];
}

+(float)edgeSpace
{
    return edge_space[device_type];
}

+(float)cardWidth
{
    return card_width[device_type];
}

+(float)cardHeight
{
    return card_height[device_type];
}

+(void)setMaxDistance:(float)x:(float)y
{
    max_distance = sqrtf(x * x + y * y);
}

+(void)setMaxAnimationDuration:(float)duration
{
    card_deal_max_animation_duration = duration;
}

+(float)cardBorderWidth
{
    return card_border_width[device_type];
}

+(float)cardNumberWidth
{
    return card_number_width[device_type];
}

+(float)cardTypeImageWidth
{
    return card_type_width[device_type];
}

+(int)cardDigitFontSize
{
    return card_font_size[device_type];
}

+(CGRect)cardLeftUpDigitRect:(CGPoint)offset:(float)digitImageHeight
{
    CGRect tmp = CGRectMake((card_edge_width[device_type] - [G4CardSize cardNumberWidth]) / 2, card_number_edge[device_type], [G4CardSize cardNumberWidth], digitImageHeight);
    tmp = CGRectOffset(tmp, offset.x, offset.y);
    return tmp;
}

+(CGRect)cardRightDownDigitRect:(CGPoint)offset:(float)digitImageHeight
{
    float x = (card_edge_width[device_type] - [G4CardSize cardNumberWidth]) / 2;
    x = [G4CardSize cardWidth] - x - [G4CardSize cardNumberWidth];
    float y = [G4CardSize cardHeight] - card_number_edge[device_type] - digitImageHeight;
    CGRect tmp = CGRectMake(x, y, [G4CardSize cardNumberWidth], digitImageHeight);
    tmp = CGRectOffset(tmp, offset.x, offset.y);
    return tmp;
}

+(CGRect)cardLeftupTypeRect:(CGPoint)offset:(CGSize)typeImageSize:(float)y
{
    CGSize scaledSize = [G4CardSize calcScaledSize:typeImageSize :card_type_width[device_type]];
    CGRect rect;
    rect.origin.x = (card_edge_width[device_type] - card_type_width[device_type]) / 2;
    rect.origin.y = y;
    rect.size = scaledSize;
    rect = CGRectOffset(rect, offset.x, offset.y);
    return rect;
}

+(CGRect)cardRightDownTypeRect:(CGPoint)offset:(CGSize)typeImageSize:(float)y
{
    CGSize scaledSize = [G4CardSize calcScaledSize:typeImageSize :card_type_width[device_type]];
    CGRect rect;
    rect.origin.x = [G4CardSize cardWidth] - scaledSize.width - (card_edge_width[device_type] - card_type_width[device_type]) / 2;
    rect.origin.y = [G4CardSize cardHeight] - y - scaledSize.height;
    rect.size = scaledSize;
    rect = CGRectOffset(rect, offset.x, offset.y);   
    return rect; 
}

+(CGRect)cardCenterImageRect:(CGPoint)offset:(CGSize)typeImageSize
{
    float scaledWidth = card_width[device_type] - 2 * card_edge_width[device_type] - 2;
    float x = (card_width[device_type] - scaledWidth) / 2;
    CGSize scaledSize = [G4CardSize calcScaledSize:typeImageSize :scaledWidth];
    float y = (card_height[device_type] - scaledSize.height) / 2;
    CGRect rect;
    rect.origin = CGPointMake(x, y);
    rect.size = scaledSize;
    rect = CGRectOffset(rect, offset.x, offset.y);
    return rect;
}

+(CGSize)calcScaledSize:(CGSize)origSize:(float)scaledWidth
{
    float scale = scaledWidth / origSize.width;
    return CGSizeMake(scaledWidth, origSize.height * scale);
}

+(CGRect)cardJokerLeftRect:(CGPoint)offset
{
    float height = card_height[device_type] / 3 * 2;
    float y = card_number_edge[device_type] + offset.y;
    float x = (card_edge_width[device_type] - card_number_width[device_type]) / 2 + offset.x;
    return CGRectMake(x, y, card_number_width[device_type], height);
}

+(CGRect)cardJokerRightRect:(CGPoint)offset
{
    float height = card_height[device_type] / 3 * 2;
    float y = card_height[device_type] - card_number_edge[device_type] - height;
    float x = card_width[device_type] - (card_edge_width[device_type] - card_number_width[device_type]) / 2 - card_number_width[device_type];
    return CGRectMake(x + offset.x, y + offset.y, card_number_width[device_type], height);
}

+(CGSize)deviceViewSize
{
    return CGSizeMake(device_view_width[device_type], device_view_height[device_type]);
}

+(CGPoint)calcCardCenter:(CGPoint)leftupPoint
{
    leftupPoint.x += [G4CardSize cardWidth] / 2;
    leftupPoint.y += [G4CardSize cardHeight] / 2;
    return leftupPoint;
}

+(float)calcDealPokerAnimationDuration:(float)x:(float)y
{
    float distance = sqrtf(x * x + y * y);
    return (card_deal_max_animation_duration * distance / max_distance);
}

+(CGPoint)calcCenter:(CGRect)rect
{
    CGPoint pt = rect.origin;
    pt.x += rect.size.width / 2;
    pt.y += rect.size.height / 2;
    return pt;
}

+(float)cardMaxShowWidth
{
    return card_max_show_width[device_type];
}

+(CGRect)selfCardGroupRect
{
    float x = edge_space[device_type];
    float y = device_view_height[device_type] - card_height[device_type] - edge_space[device_type];
    return CGRectMake(x, y, device_view_width[device_type] - 2 * edge_space[device_type], card_height[device_type]);
}

+(CGRect)selfOutGroupRect
{
    float x = (device_view_width[device_type] - [G4CardSize outGroupWidth]) / 2;
    float y = device_view_height[device_type] - 2 * (edge_space[device_type] + card_height[device_type]);
    return CGRectMake(x, y, [G4CardSize outGroupWidth], card_height[device_type]);
}

+(CGRect)leftOutGroupRect
{
    float x = edge_space[device_type];
    float y = edge_space[device_type];
    return CGRectMake(x, y, [G4CardSize outGroupWidth], card_height[device_type]);
}

+(CGRect)upOutGroupRect
{
    float x = (device_view_width[device_type] - [G4CardSize outGroupWidth]) / 2;
    float y = edge_space[device_type];
    return CGRectMake(x, y, [G4CardSize outGroupWidth], card_height[device_type]);  
}

+(CGRect)rightOutGroupRect
{
    float x = device_view_width[device_type] - edge_space[device_type] - card_height[device_type];
    float y = edge_space[device_type];
    return CGRectMake(x, y, [G4CardSize outGroupWidth], card_height[device_type]); 
}

+(float)outGroupWidth
{
    float width1 = device_view_height[device_type] - 3 * edge_space[device_type] - card_height[device_type];
    float width2 = device_view_width[device_type] - 2 * card_height[device_type] - 4 * edge_space[device_type];
    if(width1 > width2)
        width1 = width2;
    return width1;
}

+(float)cardMinShowWidth
{
    return card_min_show_width[device_type];
}

+(CGSize)swapSizeWidthHeight:(CGSize)size
{
    return CGSizeMake(size.height, size.width);
}

+(float)waitingViewFontSize
{
    return waiting_view_font_size[device_type];
}

+(float)lineWidth
{
    return line_width[device_type];
}

+(float)waitingViewHeight
{
    return  waiting_view_player_name_y[device_type] + waiting_view_player_name_height[device_type] * 3 + 3 + waiting_view_info_edge[device_type];
}
+(float)waitingViewWidth
{
    return  waiting_view_width[device_type];
}

+(float)waitingViewInfoX
{
    return  waiting_view_info_x[device_type];
}

+(float)waitingViewPlayerNameY
{
    return  waiting_view_player_name_y[device_type];
}

+(float)waitingViewPlayerNameHeight
{
    return  waiting_view_player_name_height[device_type];
}

+(float)waitingViewInfoEdge
{
    return  waiting_view_info_edge[device_type];
}

+(float)waitingViewImageHeight
{
    return waiting_view_image_height[device_type];
}

+(float)adViewHeight
{
    return ad_view_height[device_type];
}

+(float)playerInfoBoardSize
{
    return player_board_info_size[device_type];
}

+(float)playerImageSize
{
    return player_image_size[device_type];
}

+(float)playerBoardFontSize
{
    return player_board_font_size[device_type];
}

+(CGPoint)leftBoardPosition
{
    float y = ([G4CardSize deviceViewSize].height - [G4CardSize playerInfoBoardSize]) / 2;
    float x = [G4CardSize edgeSpace];
    
    return CGPointMake(x, y);
}

+(CGPoint)selfBoardPosition
{
    float x = ([G4CardSize deviceViewSize].width - [G4CardSize playerInfoBoardSize]) / 2;
    float y = [G4CardSize deviceViewSize].height - 2 * [G4CardSize edgeSpace] - [G4CardSize playerInfoBoardSize] - [G4CardSize cardHeight];
    
    return CGPointMake(x, y);
}

+(CGPoint)rightBoardPosition
{
    float y = ([G4CardSize deviceViewSize].height - [G4CardSize playerInfoBoardSize]) / 2;
    float x = [G4CardSize deviceViewSize].width - [G4CardSize playerInfoBoardSize] - [G4CardSize edgeSpace];
    
    return CGPointMake(x, y);
}

+(CGPoint)upBoardPosition
{
    float x = ([G4CardSize deviceViewSize].width - [G4CardSize playerInfoBoardSize]) / 2;
    float y = [G4CardSize edgeSpace];
    
    return CGPointMake(x, y);
}

+(float)watcherSize
{
    return watcher_size[device_type];
}

+(float)cardSelectedUp
{
    return card_select_up[device_type];
}

+(CGRect)leftFloatRect
{
    float y = ([G4CardSize deviceViewSize].height - float_info_height[device_type]) / 2;
    float x = [G4CardSize edgeSpace] + [G4CardSize playerInfoBoardSize] + 1;
    
    return CGRectMake(x, y, float_info_width[device_type], float_info_height[device_type]);

}

+(CGRect)selfFloatRect
{
    float x = ([G4CardSize deviceViewSize].width - float_info_width[device_type]) / 2;
    float y = [G4CardSize deviceViewSize].height - 2 * [G4CardSize edgeSpace] - float_info_height[device_type] - [G4CardSize cardHeight];
    
    return CGRectMake(x, y, float_info_width[device_type], float_info_height[device_type]);
}

+(CGRect)rightFloatRect
{
    float y = ([G4CardSize deviceViewSize].height - float_info_height[device_type]) / 2;
    float x = [G4CardSize deviceViewSize].width - [G4CardSize playerInfoBoardSize] - [G4CardSize edgeSpace] - float_info_width[device_type];
    return CGRectMake(x, y, float_info_width[device_type], float_info_height[device_type]);
}

+(CGRect)upFloatRect
{
    float x = ([G4CardSize deviceViewSize].width - float_info_width[device_type]) / 2;
    float y = [G4CardSize edgeSpace] + [G4CardSize playerInfoBoardSize];
    return CGRectMake(x, y, float_info_width[device_type], float_info_height[device_type]);
}

+(CGPoint)playerWatcherPoint:(char)direction
{
    float x = 0;
    float y = 0;
    switch (direction) {
        case GROUP_DIRECTION_LEFT:
            y = ([G4CardSize deviceViewSize].height - watcher_size[device_type]) / 2;
            x = [G4CardSize edgeSpace] + [G4CardSize playerInfoBoardSize] + 1;
            break;
        case GROUP_DIRECTION_ME:
            x = ([G4CardSize deviceViewSize].width - watcher_size[device_type]) / 2;
            y = [G4CardSize deviceViewSize].height - 2 * [G4CardSize edgeSpace] - watcher_size[device_type] - [G4CardSize cardHeight] - cmd_pannel_height[device_type] - card_select_up[device_type];
            break;
        case GROUP_DIRECTION_RIGHT:
            y = ([G4CardSize deviceViewSize].height - watcher_size[device_type]) / 2;
            x = [G4CardSize deviceViewSize].width - [G4CardSize playerInfoBoardSize] - [G4CardSize edgeSpace] - watcher_size[device_type];
            break;
        case GROUP_DIRECTION_UP:
            x = ([G4CardSize deviceViewSize].width - watcher_size[device_type]) / 2;
            y = [G4CardSize edgeSpace] + [G4CardSize playerInfoBoardSize];
            break;
        default:
            break;
    } 
    return CGPointMake(x, y);
}

+(float)floatInfoFontSize
{
    return float_info_font_size[device_type];
}

+(CGRect)cmdPannelRect
{
    float x = (device_view_width[device_type] - cmd_pannel_width[device_type]) / 2;
    float y = device_view_height[device_type] - card_height[device_type] - 2 * edge_space[device_type] - cmd_pannel_height[device_type] - card_select_up[device_type];
    
    return CGRectMake(x, y, cmd_pannel_width[device_type], cmd_pannel_height[device_type]);
}

+(float)cmdButtonWidth
{
    return cmd_button_width[device_type];
}

+(CGPoint)lanImagePosition
{
    return CGPointMake(lan_image_x[device_type], mode_image_y[device_type]);
}

+(CGPoint)gamecenterImagePostion
{
    return CGPointMake(game_center_image_x[device_type], mode_image_y[device_type]);
}

+(float)sizeOfModeImage
{
    return mode_image_size[device_type];
}

+(float)resultNameWidth
{
    return result_name_width[device_type];
}

+(float)resultTotalScoreWidth
{
    return result_total_score_width[device_type];
}

+(float)resultRoundScoreWidth
{
    return result_round_score_width[device_type];
}

+(float)resultCellHeight
{
    return result_cell_height[device_type];
}

+(float)resultFontSize
{
    return result_font_size[device_type];
}

@end
