using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/*

Produces an simple tracking/letter-spacing effect on UI Text components.

Set the spacing parameter to adjust letter spacing.
  Negative values cuddle the text up tighter than normal. Go too far and it'll look odd.
  Positive values spread the text out more than normal. This will NOT respect the text area you've defined.
  Zero spacing will present the font with no changes.

Relies on counting off characters in your Text compoennt's text property and
matching those against the quads passed in via the verts array. This is really
rather primative, but I can't see any better way at the moment. It means that
all sorts of things can break the effect...

This component should be placed higher in component list than any other vertex
modifiers that alter the total number of verticies. Eg, place this above Shadow
or Outline effects. If you don't, the outline/shadow won't match the position
of the letters properly. If you place the outline/shadow effect second however,
it will just work on the altered vertices from this component, and function
as expected.

This component works best if you don't allow text to automatically wrap. It also
blows up outside of the given text area. Basically, it's a cheap and dirty effect,
not a clever text layout engine. It can't affect how Unity chooses to break up
your lines. If you manually use line breaks however, it should detect those and
function more or less as you'd expect.

The spacing parameter is measured in pixels multiplied by the font size. This was
chosen such that when you adjust the font size, it does not change the visual spacing
that you've dialed in. There's also a scale factor of 1/100 in this number to
bring it into a comfortable adjustable range. There's no limit on this parameter,
but obviously some values will look quite strange.

This component doesn't really work with Rich Text. You don't need to remember to
turn off Rich Text via the checkbox, but because it can't see what makes a
printable character and what doesn't, it will typically miscount characters when you
use HTML-like tags in your text. Try it out, you'll see what I mean. It doesn't
break down entirely, but it doesn't really do what you'd want either.

*/

//wugj：原来一个字4个顶点现在变为了6个，一些老的API被废弃，做了相应的调整，会出现自动换行的多行文本请勿使用
namespace UnityEngine.UI
{
	[AddComponentMenu("UI/Effects/Advanced Letter Spacing", 14)]
    [ExecuteInEditMode]
    public class AdvancedLetterSpacing : BaseMeshEffect
	{
		[SerializeField]
		private float m_spacing = 0f;
        private string oldText = "";
        private float oldSpacing = 0f;
        private Vector2 oldSize;
        private Text text;
        private RectTransform rect;

        protected AdvancedLetterSpacing() { }

        protected override void Start()
        {
            if (text == null)
            {
                text = GetComponent<Text>();
                oldText = text.text;
                rect = GetComponent<RectTransform>();
                oldSize = rect.sizeDelta;
                oldSpacing = m_spacing;   
            }
            if (text == null)
            {
                TTLoger.LogWarning("LetterSpacing: Missing Text component");
                return;
            }
        }

        void Update() 
        {
            if (text.text != oldText)
            {
                text.text = ProcessChangeLine(text.text);
                if (graphic != null) graphic.SetVerticesDirty();
            }
            else if (rect.sizeDelta != oldSize) 
            {
                text.text = ProcessChangeLine(text.text);
                if (graphic != null) graphic.SetVerticesDirty();
            }
        }
		
		#if UNITY_EDITOR
		protected override void OnValidate()
		{
			spacing = m_spacing;
			base.OnValidate();
		}
		#endif
		
		public float spacing
		{
			get { return m_spacing; }
			set
			{
                if (oldSpacing == value || text == null) return;
                oldSpacing = value;               
                text.text = ProcessChangeLine(text.text);
				if (graphic != null) graphic.SetVerticesDirty();
			}
		}

        public float ScaleFactor = 100f;
        public float offsetFactor = 0f;

        private string ProcessChangeLine(string input)
        {
            Text text = GetComponent<Text>();
            TextGenerator gen = new TextGenerator();

            float LineWidth = GetComponent<RectTransform>().sizeDelta.x;
            //char[] charArr = input.ToCharArray();
            TextGenerationSettings setting = new TextGenerationSettings();
            setting.font = text.font;
            setting.fontSize = text.fontSize;
            setting.lineSpacing = 1;
            setting.scaleFactor = 1;
            setting.verticalOverflow = VerticalWrapMode.Overflow;
            setting.horizontalOverflow = HorizontalWrapMode.Overflow;

            float realSpacing = spacing * (float)text.fontSize / ScaleFactor + offsetFactor;

            //string rest = input;
            string output = "";
            float currLength = 0f;
            for (int i = 0; i < input.Length; ++i)
            {
                char c = input[i];
                float letterLength = gen.GetPreferredWidth(new string(c, 1), setting) / text.pixelsPerUnit;

                if (c == '\n')
                {
                    continue;
                    //output += c;
                    //currLength = 0;
                }
                //这一行还没有满
                else if (currLength + letterLength <= LineWidth)
                {
                    currLength = currLength + letterLength + realSpacing;
                    output += c;
                }
                //该行已满，换行，累计宽度重新计算
                else
                {
                    output += "\n";
                    currLength = letterLength + realSpacing;
                    output += c;
                }
            }

            oldText = output;
            //从第一个字符开始计算第一行的字符数 
            //rendElem.width = (int)gen.GetPreferredWidth(rendElem.strChar, setting);
            return output;
        }


        RichText rt = new RichText();


        public override void ModifyMesh(VertexHelper helper)//List<UIVertex> verts
		{
			if (! IsActive()) return;

            List<UIVertex> verts = new List<UIVertex>();
            helper.GetUIVertexStream(verts);
			
			Text text = GetComponent<Text>();
			if (text == null)
			{
				TTLoger.LogWarning("LetterSpacing: Missing Text component");
				return;
			}

            string s = text.text;

            rt.ParseRichText(s);

			string[] lines = s.Split('\n');
			Vector3  pos;
            float letterOffset = spacing * (float)text.fontSize / ScaleFactor;
			float    alignmentFactor = 0;
			
			switch (text.alignment)
			{
			case TextAnchor.LowerLeft:
			case TextAnchor.MiddleLeft:
			case TextAnchor.UpperLeft:
				alignmentFactor = 0f;
				break;
				
			case TextAnchor.LowerCenter:
			case TextAnchor.MiddleCenter:
			case TextAnchor.UpperCenter:
				alignmentFactor = 0.5f;
				break;
				
			case TextAnchor.LowerRight:
			case TextAnchor.MiddleRight:
			case TextAnchor.UpperRight:
				alignmentFactor = 1f;
				break;
			}
			
            // 遍历所有行
			for (int lineIdx=0; lineIdx < lines.Length; lineIdx++)
			{
                // 获取行
				string line = lines[lineIdx];
                // 计算行偏移
                float lineOffset = (line.Length - 1) * letterOffset * alignmentFactor;
                // 遍历行对象
                for (int i = 0; i < rt.root.childCount; ++i )
                {
                    // 获取行对象
                    RichTextSegment lineSeg = rt.root.GetChild(i) as RichTextSegment;
                    
                    int startShowGlyphIndexInLine = 0;

                    // 遍历行内对象
                    for(int k = 0; k < lineSeg.childCount; ++k)
                    {
                        // 获取行内对象
                        RichTextSegment child = lineSeg.GetChild(k);
                        
                        // 
                        for (int showGlyphIdx = 0; showGlyphIdx < child.showGlyphCount; ++showGlyphIdx)
                        {

                            int glyphIndex = child.startIndex + showGlyphIdx;

                            int idx1 = glyphIndex * 6 + 0;
                            int idx2 = glyphIndex * 6 + 1;
                            int idx3 = glyphIndex * 6 + 2;
                            int idx4 = glyphIndex * 6 + 3;
                            int idx5 = glyphIndex * 6 + 4;
                            int idx6 = glyphIndex * 6 + 5;

                            if (idx6 > verts.Count - 1)
                                return;

                            UIVertex vert1 = verts[idx1];
                            UIVertex vert2 = verts[idx2];
                            UIVertex vert3 = verts[idx3];
                            UIVertex vert4 = verts[idx4];
                            UIVertex vert5 = verts[idx5];
                            UIVertex vert6 = verts[idx6];

                            float f = (letterOffset * (startShowGlyphIndexInLine + showGlyphIdx) - lineOffset);                           
                            pos = Vector3.right * f;

                            vert1.position += pos;
                            vert2.position += pos;
                            vert3.position += pos;
                            vert4.position += pos;
                            vert5.position += pos;
                            vert6.position += pos;

                            verts[idx1] = vert1;
                            verts[idx2] = vert2;
                            verts[idx3] = vert3;
                            verts[idx4] = vert4;
                            verts[idx5] = vert5;
                            verts[idx6] = vert6;
                        }

                        startShowGlyphIndexInLine += child.showGlyphCount;
                        
                    }

                }

			}

            helper.Clear();
            helper.AddUIVertexTriangleStream(verts);
		}
	}
}
